import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tribe/core/config/api_config.dart';
import 'package:tribe/core/storage/token_storage_service.dart';

enum WebSocketEventType {
  messageNew,
  messageRead,
  typing,
  presence,
  error,
  connected,
  disconnected,
}

class WebSocketMessage {
  final WebSocketEventType event;
  final Map<String, dynamic>? data;
  final String? conversationId;

  WebSocketMessage({
    required this.event,
    this.data,
    this.conversationId,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    WebSocketEventType eventType;
    final eventStr = json['event'] as String?;
    
    switch (eventStr) {
      case 'message.new':
        eventType = WebSocketEventType.messageNew;
        break;
      case 'message.read':
        eventType = WebSocketEventType.messageRead;
        break;
      case 'typing':
        eventType = WebSocketEventType.typing;
        break;
      case 'presence':
        eventType = WebSocketEventType.presence;
        break;
      case 'error':
        eventType = WebSocketEventType.error;
        break;
      default:
        eventType = WebSocketEventType.error;
    }

    return WebSocketMessage(
      event: eventType,
      data: json['data'] as Map<String, dynamic>? ?? json,
      conversationId: json['conversation_id'] as String?,
    );
  }
}

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  final TokenStorageService _tokenStorage = TokenStorageService();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final Set<String> _subscribedConversations = {};
  Completer<void>? _connectionCompleter;

  Stream<WebSocketMessage> get messageStream => 
      _messageController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected && _channel != null) {
      return;
    }

    // If already connecting, wait for that connection
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      return _connectionCompleter!.future;
    }

    _connectionCompleter = Completer<void>();

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      // Convert HTTP URL to WebSocket URL
      final baseUrl = ApiConfig.apiBaseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final wsUrl = '$baseUrl/ws?token=$token';

      print('🔌 WebSocket: Connecting to $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _messageController ??= StreamController<WebSocketMessage>.broadcast();

      _channel!.stream.listen(
        (message) {
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final wsMessage = WebSocketMessage.fromJson(json);
            print('📨 WebSocket: Received message - ${wsMessage.event}');
            _messageController?.add(wsMessage);
            
            // Mark as connected when we receive the first message
            if (!_isConnected && wsMessage.event == WebSocketEventType.connected) {
              _isConnected = true;
              _connectionCompleter?.complete();
              print('✅ WebSocket: Connection established');
            }
          } catch (e) {
            print('❌ WebSocket: Error parsing message: $e');
            // Handle non-JSON messages or connection events
            if (message.toString().contains('connected')) {
              _isConnected = true;
              _connectionCompleter?.complete();
              _messageController?.add(WebSocketMessage(
                event: WebSocketEventType.connected,
              ));
            }
          }
        },
        onError: (error) {
          print('❌ WebSocket: Connection error: $error');
          _isConnected = false;
          _connectionCompleter?.completeError(error);
          _messageController?.add(WebSocketMessage(
            event: WebSocketEventType.error,
            data: {'error': error.toString()},
          ));
          _scheduleReconnect();
        },
        onDone: () {
          print('🔌 WebSocket: Connection closed');
          _isConnected = false;
          _connectionCompleter?.complete();
          _messageController?.add(WebSocketMessage(
            event: WebSocketEventType.disconnected,
          ));
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _startHeartbeat();
      
      // Wait for connection confirmation with timeout
      try {
        await _connectionCompleter!.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // If timeout, assume connection is established (might have missed the event)
            if (!_connectionCompleter!.isCompleted) {
              _isConnected = true;
              _connectionCompleter?.complete();
              print('✅ WebSocket: Connection assumed established (timeout)');
            }
          },
        );
      } catch (e) {
        print('⚠️ WebSocket: Connection confirmation timeout or error: $e');
        // Still mark as connected if channel exists
        if (_channel != null) {
          _isConnected = true;
          if (!_connectionCompleter!.isCompleted) {
            _connectionCompleter?.complete();
          }
        }
      }
      
      // Resubscribe to all conversations after connection is established
      if (_isConnected) {
        for (final conversationId in _subscribedConversations) {
          subscribeToConversation(conversationId);
        }
      }
    } catch (e) {
      print('❌ WebSocket: Connection failed: $e');
      _isConnected = false;
      _connectionCompleter?.completeError(e);
      _messageController?.add(WebSocketMessage(
        event: WebSocketEventType.error,
        data: {'error': e.toString()},
      ));
      _scheduleReconnect();
    }
  }

  Future<void> subscribeToConversation(String conversationId) async {
    _subscribedConversations.add(conversationId);
    
    if (!_isConnected || _channel == null) {
      print('📡 WebSocket: Not connected, connecting first...');
      await connect(); // Wait for connection
    }

    if (_isConnected && _channel != null) {
      print('📡 WebSocket: Subscribing to conversation $conversationId');
      _send({
        'event': 'subscribe',
        'channel': 'conversation',
        'conversation_id': conversationId,
      });
    } else {
      print('⚠️ WebSocket: Still not connected after connect() call');
    }
  }

  void unsubscribeFromConversation(String conversationId) {
    _subscribedConversations.remove(conversationId);
    if (_isConnected && _channel != null) {
      _send({
        'event': 'unsubscribe',
        'channel': 'conversation',
        'conversation_id': conversationId,
      });
    }
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (!_isConnected || _channel == null) return;

    _send({
      'event': 'typing',
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  void sendPresence(String status) {
    if (!_isConnected || _channel == null) return;

    _send({
      'event': 'presence',
      'status': status,
    });
  }

  void _send(Map<String, dynamic> message) {
    if (_channel == null || !_isConnected) {
      print('⚠️ WebSocket: Cannot send - channel is null or not connected');
      return;
    }
    try {
      final messageStr = jsonEncode(message);
      print('📤 WebSocket: Sending - ${message['event']}');
      _channel!.sink.add(messageStr);
    } catch (e) {
      print('❌ WebSocket: Error sending message: $e');
      // Mark as disconnected if send fails
      _isConnected = false;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        _send({'event': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscribedConversations.clear();
    await _channel?.sink.close();
    await _messageController?.close();
    _channel = null;
    _messageController = null;
    _isConnected = false;
  }
}

