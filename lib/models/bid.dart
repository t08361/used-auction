//입찰 기록 테이블
class Bid{
  final String bid_id; // 입찰 테이블 식별자
  final String item_id; // 상품 id
  final String bidder_id; // 입찰자 id
  final int bid_amount; // 입찰 금액
  final DateTime bid_time; // 입찰한 시간

  Bid({
    required this.bid_id,
    required this.item_id,
    required this.bidder_id,
    required this.bid_amount,
    required this.bid_time,
  });

  Map<String, dynamic> toJson() => {
    'bid_id' : bid_id,
    'item_id' : item_id,
    'bidder_id' : bidder_id,
    'bid_amount' : bid_amount,
    'bid_time' : bid_time.toIso8601String()
  };

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      bid_id: json['bid_id'],
      item_id: json['item_id'],
      bidder_id: json['bidder_id'],
      bid_amount : json['bid_amount'],
      bid_time : DateTime.parse(json['bid_time'])
    );
  }
}
