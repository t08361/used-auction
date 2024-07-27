import 'package:flutter/material.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime;
  final int bidUnit;
  final List<String> itemImages;
  final String userId;
  final String winnerId;
  final int lastPrice; // 현재 최고가
  final String region; // 지역 필드 추가

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
    required this.itemImages,
    required this.userId,
    required this.winnerId,
    required this.lastPrice,
    required this.region // 생성자에 추가
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'endDateTime': endDateTime.toIso8601String(),
    'bidUnit': bidUnit,
    'itemImages': itemImages,
    'userId': userId,
    'winnerId': winnerId,
    'lastPrice': lastPrice,
    'region': region, // toJson에 추가
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Untitled',
        description: json['description'] ?? '',
        price: json['price'] ?? 0,
        endDateTime: DateTime.parse(json['endDateTime'] ?? DateTime.now().toIso8601String()),
        bidUnit: json['bidUnit'] ?? 1,
        itemImages: List<String>.from(json['itemImages'] ?? []),
        winnerId: json['winnerId'] ?? '',
        userId: json['userId'] ?? '',
        lastPrice: json['lastPrice'] ?? 0,
        region: json['region'] ?? 'Unknown' // fromJson에 추가
    );
  }
}
