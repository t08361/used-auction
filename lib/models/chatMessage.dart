class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': chatRoomId,
    'senderId': senderId,
    'recipientId': recipientId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
  // 'message'라는 getter 추가
  String get message => content;
}