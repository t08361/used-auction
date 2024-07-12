class ChatRoom {
  final String id;  // chatRoomId와 일치
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerId': sellerId,
    'sellerNicname' : sellerNickname,
    'buyerId': buyerId,
    'buyerNicname' : buyerNickname,
    'finalPrice': finalPrice,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'itemImage': itemImage,
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      sellerId: json['sellerId'],
      sellerNickname: json['sellerNicname'],
      buyerId: json['buyerId'],
      buyerNickname: json['buyerNicname'],
      finalPrice: json['finalPrice'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      itemImage: json['itemImage'],
    );
  }
}
