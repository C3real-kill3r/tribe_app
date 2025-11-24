class AICoachService {
  Future<String> getResponse(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    if (message.toLowerCase().contains('hello')) {
      return "Hi there! I'm your Tribe Coach. How can I help you strengthen your friendships today?";
    } else if (message.toLowerCase().contains('friend')) {
      return "It sounds like you're thinking about your friends. Have you checked in with them lately?";
    } else {
      return "That's interesting! Tell me more. I'm here to help you stay connected.";
    }
  }
}
