import 'package:flutter/material.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime;
  final int bidUnit;
  final String itemImage;
  final String userId;
  final String winnerId;
  final int lastPrice;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
    required this.itemImage,
    required this.userId,
    required this.winnerId,
    required this.lastPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'endDateTime': endDateTime.toIso8601String(),
    'bidUnit': bidUnit,
    'itemImage': itemImage,
    'userId': userId,
    'winnerId': winnerId,
    'lastPrice': lastPrice,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      endDateTime: DateTime.parse(json['endDateTime'] ?? DateTime.now().toIso8601String()),
      bidUnit: json['bidUnit'] ?? 1,
      itemImage: json['itemImage'] ?? '', // 기본 값을 빈 문자열로 설정
      userId: json['userId'] ?? '',
      winnerId: json['winnerId'] ?? '',
      lastPrice: json['lastPrice'] ?? 0,
    );
  }
}
