import 'dart:io';

class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime; // 경매 종료 시간
  final int bidUnit; // 입찰 단위
  final File imageFile;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
    required this.imageFile,
  });
}