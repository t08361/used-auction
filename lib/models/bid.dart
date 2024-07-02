import 'dart:io';

//입찰 기록 테이블
class Bid{
  final String bid_id;
  final String item_id;
  final String bidder_id;
  final String bid_amount;
  final String bid_time;

  Bid({
    required this.bid_id,
    required this.item_id,
    required this.bidder_id,
    required this.bid_amount,
    required this.bid_time,
  });
}
