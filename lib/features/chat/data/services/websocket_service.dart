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
  subscribed,
  pong,
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
      case 'connected':
        eventType = WebSocketEventType.connected;
        break;
      case 'subscribed':
        eventType = WebSocketEventType.subscribed;
        break;
      case 'pong':
        eventType = WebSocketEventType.pong;
        break;
      case 'error':
        eventType = WebSocketEventType.error;
        break;
      default:
        // Unknown event type - log but don't treat as error
        print('⚠️ WebSocket: Unknown event type: $eventStr');
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
  StreamSubscription<dynamic>? _streamSubscription;
  bool _isReconnecting = false;

  Stream<WebSocketMessage> get messageStream => 
      _messageController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected && _channel != null && !_isReconnecting) {
      return;
    }

    // If already connecting, wait for that connection
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      return _connectionCompleter!.future;
    }

    // Clean up existing connection
    await _cleanupConnection();

    _isReconnecting = false;
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

      _streamSubscription = _channel!.stream.listen(
        (message) {
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final wsMessage = WebSocketMessage.fromJson(json);
            print('📨 WebSocket: Received message - ${wsMessage.event}');
            
            // Handle connection confirmation
            if (wsMessage.event == WebSocketEventType.connected) {
              _isConnected = true;
              _isReconnecting = false;
              if (!_connectionCompleter!.isCompleted) {
                _connectionCompleter?.complete();
              }
              print('✅ WebSocket: Connection established');
              _messageController?.add(wsMessage);
              return;
            }
            
            // Handle subscription confirmation
            if (wsMessage.event == WebSocketEventType.subscribed) {
              print('✅ WebSocket: Subscribed to conversation ${wsMessage.conversationId}');
              _messageController?.add(wsMessage);
              return;
            }
            
            // Handle pong (heartbeat response)
            if (wsMessage.event == WebSocketEventType.pong) {
              // Silently handle pong - no need to broadcast
              return;
            }
            
            // Don't process error events from server as regular messages
            if (wsMessage.event == WebSocketEventType.error) {
              print('⚠️ WebSocket: Server sent error event: ${wsMessage.data}');
              // Handle server error - might indicate connection issue
              final errorMsg = wsMessage.data?['error']?.toString() ?? 
                              wsMessage.data?['message']?.toString() ?? 
                              'Unknown error';
              _handleConnectionError('Server error: $errorMsg');
              return;
            }
            
            // Broadcast all other events
            _messageController?.add(wsMessage);
          } catch (e) {
            print('❌ WebSocket: Error parsing message: $e');
            // Handle non-JSON messages or connection events
            if (message.toString().contains('connected')) {
              _isConnected = true;
              _isReconnecting = false;
              if (!_connectionCompleter!.isCompleted) {
                _connectionCompleter?.complete();
              }
              _messageController?.add(WebSocketMessage(
                event: WebSocketEventType.connected,
              ));
            } else {
              // Invalid message format - might indicate connection issue
              print('⚠️ WebSocket: Received invalid message format');
            }
          }
        },
        onError: (error) {
          print('❌ WebSocket: Stream error: $error');
          _handleConnectionError(error.toString());
        },
        onDone: () {
          print('🔌 WebSocket: Stream closed');
          _handleConnectionClosed();
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
        // Delay resubscription slightly to ensure connection is stable
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isConnected) {
            for (final conversationId in _subscribedConversations) {
              subscribeToConversation(conversationId);
            }
          }
        });
      }
    } catch (e) {
      print('❌ WebSocket: Connection failed: $e');
      _isConnected = false;
      _isReconnecting = false;
      if (!_connectionCompleter!.isCompleted) {
        _connectionCompleter?.completeError(e);
      }
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

  void _handleConnectionError(String error) {
    if (_isReconnecting) return; // Already handling reconnection
    
    _isConnected = false;
    _isReconnecting = true;
    
    if (!_connectionCompleter!.isCompleted) {
      _connectionCompleter?.completeError(error);
    }
    
    _messageController?.add(WebSocketMessage(
      event: WebSocketEventType.error,
      data: {'error': error},
    ));
    
    _scheduleReconnect();
  }

  void _handleConnectionClosed() {
    if (_isReconnecting) return; // Already handling reconnection
    
    _isConnected = false;
    _isReconnecting = true;
    
    if (!_connectionCompleter!.isCompleted) {
      _connectionCompleter?.complete();
    }
    
    _messageController?.add(WebSocketMessage(
      event: WebSocketEventType.disconnected,
    ));
    
    _scheduleReconnect();
  }

  Future<void> _cleanupConnection() async {
    _heartbeatTimer?.cancel();
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    
    try {
      await _channel?.sink.close();
    } catch (e) {
      print('⚠️ WebSocket: Error closing channel: $e');
    }
    
    _channel = null;
    _isConnected = false;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null && !_isReconnecting) {
        try {
          _send({'event': 'ping'});
        } catch (e) {
          print('❌ WebSocket: Error sending ping: $e');
          // Connection might be broken, trigger reconnection
          _handleConnectionError('Ping failed: $e');
        }
      } else {
        // Stop heartbeat if not connected
        timer.cancel();
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isReconnecting) {
        print('🔄 WebSocket: Attempting to reconnect...');
        _isReconnecting = true;
        connect().catchError((e) {
          print('❌ WebSocket: Reconnection failed: $e');
          _isReconnecting = false;
          _scheduleReconnect(); // Retry after delay
        });
      }
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscribedConversations.clear();
    _isReconnecting = false;
    await _cleanupConnection();
    await _messageController?.close();
    _messageController = null;
  }
}

