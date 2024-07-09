class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final int timestamp;

  ChatMessage({required this.id, required this.senderId, required this.receiverId, required this.message, required this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}