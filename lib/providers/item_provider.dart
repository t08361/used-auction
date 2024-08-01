import 'dart:convert'; // JSON 변환을 위한 패키지
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지
import '../models/item.dart'; // Item 모델
import 'constants.dart';

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
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List<dynamic>; // JSON 응답을 디코드하여 리스트로 변환
        final List<Item> loadedItems = []; // 로드된 아이템을 저장할 리스트 초기화
        for (var itemData in extractedData) {
          loadedItems.add(Item.fromJson(itemData)); // JSON 데이터를 Item 객체로 변환하여 리스트에 추가
        }
        _items = loadedItems; // _items 리스트 업데이트
        notifyListeners(); // 상태 변경 알림
      } else {
        // 서버 응답 상태 코드와 응답 본문을 출력하여 문제 진단
        print('Failed to load items. Status code: ${response.statusCode}'); // 오류 출력
        print('Response body: ${response.body}');
        throw Exception('Failed to load items');
      }
    } catch (error) {
      print('Error: $error'); // 에러 메시지와 함께 응답 상태 코드와 응답 본문을 출력
      rethrow;
    }
  }

  // 새로운 아이템을 추가하는 메서드
  Future<void> addItem(Item item) async {
    final url = Uri.parse('$baseUrl/items'); // 서버 URL
    try {
      final response = await http.post(
        url, // HTTP POST 요청 보내기
        headers: {'Content-Type': 'application/json'}, // JSON 형식으로 요청
        body: json.encode(item.toJson()), // 아이템 데이터를 JSON 형식으로 변환하여 요청 본문에 추가
      );
      if (response.statusCode == 201) { // 응답 상태 코드가 201 (Created)인 경우
        _items.add(item); // 아이템 리스트에 추가
        notifyListeners(); // 상태 변경 알림
      } else {
        throw Exception('Failed to add item'); // 실패 시 예외 던지기
      }
    } catch (error) {
      rethrow; // 에러 발생 시 예외 던지기
    }
  }

  // 아이템을 삭제하는 메서드
  Future<void> deleteItem(String id) async {
    final url = Uri.parse('$baseUrl/items/$id'); // 서버 URL
    final existingItemIndex = _items.indexWhere((item) =>
    item.id == id); // 삭제할 아이템의 인덱스를 찾기
    var existingItem = _items[existingItemIndex]; // 삭제할 아이템 저장
    _items.removeAt(existingItemIndex); // 아이템 리스트에서 삭제
    notifyListeners(); // 상태 변경 알림

    final response = await http.delete(url); // HTTP DELETE 요청 보내기
    if (response.statusCode >= 400) { // 응답 상태 코드가 400 이상인 경우
      _items.insert(existingItemIndex, existingItem); // 삭제 실패 시 아이템을 다시 리스트에 추가
      notifyListeners(); // 상태 변경 알림
      throw Exception('Failed to delete item'); // 예외 던지기
    }
  }

  // 아이템을 수정하는 메서드
  Future<void> modifyItem(String id, String title, String description) async {
    final url = Uri.parse('$baseUrl/items/$id'); // 서버 URL
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'}, // JSON 형식으로 요청
      body: json.encode({'title': title, 'description': description}), // 변경할 아이템의 제목과 설명을 JSON으로 변환하여 요청 본문에 포함
    );

    // 서버 응답이 200(OK)일 경우에만 아이템 수정 작업 진행
    if (response.statusCode == 200) {
      final index = _items.indexWhere((item) => item.id == id); // 아이템 리스트에서 수정할 아이템의 인덱스를 찾음
      if (index != -1) { // 인덱스가 유효한 경우에만 진행
        _items[index] = Item(
          id: id,
          title: title, // 업데이트된 제목
          description: description, // 업데이트된 설명
          price: _items[index].price, // 나머지는 기존 정보 유지
          endDateTime: _items[index].endDateTime,
          bidUnit: _items[index].bidUnit,
          userId: _items[index].userId,
          winnerId: _items[index].winnerId,
          itemImages: _items[index].itemImages,
          lastPrice: _items[index].lastPrice,
          region: _items[index].region,
        );
        notifyListeners(); // 아이템 리스트가 수정되었음을 알림
      }
    } else {
      throw Exception('Failed to update item'); // 응답코드가 200이 아닌 경우 예외를 던져 오류 처리
    }
  }

  // 특정 아이템의 현재 최고가를 가져오는 메서드
  Future<int> fetchCurrentPrice(String itemId) async {
    final url = Uri.parse('$baseUrl/items/$itemId/current_price');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as int; // 응답 본문을 디코드하여 정수형 최고가 반환
      } else {
        print('Failed to load current price. Status code: ${response.statusCode}'); // 오류 상태 코드 출력
        print('Response body: ${response.body}'); // 응답 본문 내용 출력
        throw Exception('Failed to load current price'); // 예외 발생
      }
    } catch (error) {
      print('Error fetching current price: $error');
      rethrow; // 예외를 다시 던져 호출자에게 전파
    }
  }

  // 특정 아이템의 남은 시간을 가져오는 메서드
  Future<Duration> fetchRemainingTime(String itemId) async {
    final url = Uri.parse('$baseUrl/items/$itemId/remaining_time');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return Duration(minutes: json.decode(response.body) as int); // 응답 본문을 디코드하여 분 단위 Duration 객체로 반환
      } else {
        print('Failed to load remaining time. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load remaining time');
      }
    } catch (error) {
      print('Error fetching remaining time: $error');
      rethrow;
    }
  }
}
