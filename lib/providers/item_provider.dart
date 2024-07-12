import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지 import
import 'dart:convert'; // JSON 변환을 위한 dart:convert 패키지 import
import '../models/item.dart';
import 'constants.dart'; // Item 모델을 import

// ItemProvider 클래스 정의
class ItemProvider with ChangeNotifier {
  List<Item> _items = []; // 아이템 목록을 저장할 리스트

  // 아이템 목록을 반환하는 getter
  List<Item> get items {
    return [..._items]; // 아이템 리스트의 복사본을 반환
  }

  // 서버에서 아이템 목록을 가져오는 메서드
  Future<void> fetchItems() async {
    final url = Uri.parse('$baseUrl/items'); // 서버 URL
    try {
      final response = await http.get(url); // HTTP GET 요청 보내기
      final extractedData = json.decode(response.body) as List<dynamic>; // JSON 응답을 디코드하여 리스트로 변환
      final List<Item> loadedItems = []; // 로드된 아이템을 저장할 리스트
      for (var itemData in extractedData) {
        loadedItems.add(Item.fromJson(itemData)); // JSON 데이터를 Item 객체로 변환하여 리스트에 추가
      }
      _items = loadedItems; // _items 리스트를 로드된 아이템으로 업데이트
      notifyListeners(); // 상태 변경 알림
    } catch (error) {
      throw error; // 에러 발생 시 예외 던지기
    }
  }

  // 새로운 아이템을 추가하는 메서드
  Future<void> addItem(Item item) async {
    final url = Uri.parse('$baseUrl/items'); // 서버 URL
    try {
      final response = await http.post(
        url, // HTTP POST 요청 보내기
        headers: {'Content-Type': 'application/json'}, // 요청 헤더 설정
        body: json.encode(item.toJson()), // 아이템 데이터를 JSON 형식으로 변환하여 요청 본문에 추가
      );
      if (response.statusCode == 201) { // 응답 상태 코드가 201 (Created) 인 경우
        _items.add(item); // 아이템 리스트에 추가
        notifyListeners(); // 상태 변경 알림
      } else {
        throw Exception('Failed to add item'); // 실패 시 예외 던지기
      }
    } catch (error) {
      throw error; // 에러 발생 시 예외 던지기
    }
  }

  // 아이템을 삭제하는 메서드
  Future<void> deleteItem(String id) async {
    final url = Uri.parse('$baseUrl/items/$id'); // 서버 URL
    final existingItemIndex = _items.indexWhere((item) => item.id == id); // 삭제할 아이템의 인덱스를 찾기
    var existingItem = _items[existingItemIndex]; // 삭제할 아이템 저장
    _items.removeAt(existingItemIndex); // 아이템 리스트에서 삭제
    notifyListeners(); // 상태 변경 알림

    final response = await http.delete(url); // HTTP DELETE 요청 보내기
    if (response.statusCode >= 400) { // 응답 상태 코드가 400 이상인 경우
      _items.insert(existingItemIndex, existingItem); // 삭제 실패 시 아이템을 다시 리스트에 추가
      notifyListeners(); // 상태 변경 알림
      throw Exception('Failed to delete item'); // 예외 던지기
    }
    //existingItem = null; // 기존 아이템 null 처리 (필요 시 사용)
  }

  // 특정 아이템의 현재 최고가를 가져오는 메서드
  Future<int> fetchCurrentPrice(String itemId) async {
    final url = Uri.parse('$baseUrl/items/$itemId/current_price');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as int;
      } else {
        print('Failed to load current price. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load current price');
      }
    } catch (error) {
      print('Error fetching current price: $error');
      throw error;
    }
  }

  // 특정 아이템의 남은 시간을 가져오는 메서드
  Future<Duration> fetchRemainingTime(String itemId) async {
    final url = Uri.parse('$baseUrl/items/$itemId/remaining_time');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Duration(minutes: json.decode(response.body) as int);
      } else {
        print('Failed to load remaining time. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load remaining time');
      }
    } catch (error) {
      print('Error fetching remaining time: $error');
      throw error;
    }
  }
}