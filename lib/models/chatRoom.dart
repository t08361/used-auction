class ChatRoom {
  final String id;
  final String sellerId;
  final String sellerNickname;
  final String buyerId;
  final String buyerNickname;
  final int finalPrice;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String itemImage;

  ChatRoom({
    required this.id,
    required this.sellerId,
    required this.sellerNickname,
    required this.buyerId,
    required this.buyerNickname,
    required this.finalPrice,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.itemImage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerNickname: json['sellerNickname'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerNickname: json['buyerNickname'] ?? '',
      finalPrice: json['finalPrice'] ?? 0,
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : DateTime.now(),
      itemImage: json['itemImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerNickname': sellerNickname,
      'buyerId': buyerId,
      'buyerNickname': buyerNickname,
      'finalPrice': finalPrice,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'itemImage': itemImage,
    };
  }
}