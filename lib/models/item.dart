import 'package:flutter/material.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime; // DateTime 사용
  final int bidUnit;
  final String? itemImage;
  final String userId; // 상품등록한 사람 아이디(식별자)
  final int lastPrice; // 현재 최고가

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
    this.itemImage,
    required this.userId,
    required this.lastPrice
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'endDateTime': endDateTime.toIso8601String(), // DateTime을 String으로 변환
    'bidUnit': bidUnit,
    'itemImage' : itemImage,
    'userId': userId, // 추가
    'lastPrice': lastPrice,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      endDateTime: DateTime.parse(json['endDateTime']), // String을 DateTime으로 변환
      bidUnit: json['bidUnit'],
      itemImage: json['itemImage'],
      userId: json['userId'], // 추가
      lastPrice: json['lastPrice']
    );
  }
}