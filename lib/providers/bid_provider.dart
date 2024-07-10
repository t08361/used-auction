import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지 import
import 'dart:convert'; // JSON 변환을 위한 dart:convert 패키지 import
import '../models/bid.dart';
import 'constants.dart';

class BidProvider with ChangeNotifier {
  List<Bid> _bids = []; // 입찰 목록을 저장할 리스트

  List<Bid> get bids {
    return [..._bids];
  }

  // 서버에 새로운 입찰 기록을 추가하는 메서드
  Future<void> addBid(Bid bid) async {
    final url = Uri.parse('$baseUrl/bids');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bid.toJson()), // 입찰 데이터를 JSON 형식으로 변환하여 요청
      );
      if (response.statusCode == 201) {
        _bids.add(bid); // 입찰기록 리스트에 추가
        notifyListeners();
      } else{
        throw Exception('입찰기록 추가 실패');
      }
    }catch (error) {
      throw error;
    }
  }
}