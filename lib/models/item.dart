import 'dart:convert'; // JSON 변환을 위한 import
import 'package:meta/meta.dart'; // required 키워드를 사용하기 위한 import


class Item {
  final String id;
  final String title;
  final String description;
  final int price;
  final DateTime endDateTime; // 경매 종료 시간
  final int bidUnit; // 입찰 단위
  //final File imageFile;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.endDateTime,
    required this.bidUnit,
   // required this.imageFile,
  });

//item객체 데이터를 json 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'endDateTime': endDateTime.toIso8601String(),
      'bidUnit': bidUnit,
      //'imageFile': imageFile,
    };
  }
//json 데이터를 item객체로 변환
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      endDateTime: DateTime.parse(json['endDateTime']),
      bidUnit: json['bidUnit'],
      //imageFile: json['imageFile'],
    );
  }
}