import 'package:flutter/material.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime; // DateTime 사용
  final int bidUnit;
  // final String userId; // 추가
  // final String nickname; // 추가

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
    // required this.userId, // 추가
    // required this.nickname, // 추가
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
    'endDateTime': endDateTime.toIso8601String(), // DateTime을 String으로 변환
    'bidUnit': bidUnit,
    // 'userId': userId, // 추가
    // 'nickname': nickname, // 추가
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      endDateTime: DateTime.parse(json['endDateTime']), // String을 DateTime으로 변환
      bidUnit: json['bidUnit'],
      // userId: json['userId'], // 추가
      // nickname: json['nickname'], // 추가
    );
  }
}