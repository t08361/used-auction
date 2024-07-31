import 'dart:convert'; // JSON 변환을 위한 패키지 import
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지
import '../models/bid.dart'; // Bid 모델 import
import 'constants.dart';

class BidProvider with ChangeNotifier {
  final List<Bid> _bids = []; // 입찰 목록을 저장할 리스트

  List<Bid> get bids {
    return [..._bids]; // 리스트의 복사본 반환
  }

  // 서버에 새로운 입찰 기록을 추가하는 메서드
  Future<void> addBid(Bid bid) async {
    final url = Uri.parse('$baseUrl/bids'); // 서버 URL 설정
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // JSON 형식으로 요청
        body: json.encode(bid.toJson()), // 입찰 데이터를 JSON 형식으로 변환하여 요청
      );
      if (response.statusCode == 201) {
        _bids.add(bid); // 리스트에 입찰 기록 추가
        notifyListeners(); // 리스너들에게 변경 사항 알림
      } else {
        throw Exception('입찰기록 추가 실패'); // 오류 처리
      }
    } catch (error) {
      rethrow; // 예외 재발생
    }
  }
}
