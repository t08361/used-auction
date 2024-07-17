import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chatMessage.dart';
import '../models/chatRoom.dart';
import 'constants.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<ChatRoom> _chatRooms = [];

  List<ChatMessage> get messages => _messages;
  List<ChatRoom> get chatRooms => _chatRooms;

  Future<void> loadMessages(String chatRoomId) async {
    final url = Uri.parse('$baseUrl/chat/messages/$chatRoomId');
    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}'); // 상태 코드 로그 추가
      print('Response body: ${response.body}'); // 응답 본문 로그 추가

      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        //print('Extracted data: $extractedData'); // 추출된 데이터 로그 추가

        final List<ChatMessage> loadedMessages = [];
        for (var messageData in extractedData) {
          //print('Processing message: $messageData'); // 각 메시지 데이터 로그 추가
          loadedMessages.add(ChatMessage.fromJson(messageData));
        }
        _messages = loadedMessages;
        notifyListeners();
        print('Messages loaded successfully'); // 성공 로그 추가
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
        throw Exception('Failed to load messages');
      }
    } catch (error) {
      print('Error: $error'); // 오류 로그 추가
      throw Exception('Failed to load messages');
    }
  }


  Future<void> sendMessage(String chatRoomId, String senderId, String recipientId, String content, DateTime timestamp) async {
    final url = Uri.parse('$baseUrl/chat/sendMessage');
    final messageData = {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };

    print('Sending message to: $url');
    print('Message data: $messageData');

    // 데이터 유효성 검사
    if (chatRoomId.isEmpty || senderId.isEmpty || recipientId.isEmpty || content.isEmpty) {
      print('Invalid data: One of the required fields is empty');
      throw Exception('Invalid data: One of the required fields is empty');
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _messages.add(ChatMessage.fromJson(json.decode(response.body)));
        notifyListeners();
        print('Message sent successfully');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to send message');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Fail to send message');
    }
  }

  String getLastMessageForChatRoom(String chatRoomId) {
    final messagesForRoom = _messages.where((message) => message.chatRoomId == chatRoomId).toList();
    if (messagesForRoom.isNotEmpty) {
      return messagesForRoom.last.message;
    }
    return '';
  }

  Future<void> createChatRoom(String sellerId, String sellerNickname, String recipientId, String buyerNickname, String lastMessage, String imageUrl) async {
    final chatRoomId = _getChatRoomId(sellerId, recipientId);
    final existingChat = _chatRooms.any((chatRoom) => chatRoom.id == chatRoomId);
    if (!existingChat) {
      final newChatRoom = ChatRoom(
        id: chatRoomId,
        sellerId: sellerId,
        sellerNickname: sellerNickname,
        buyerId: recipientId,
        buyerNickname: buyerNickname,
        finalPrice: 0,
        lastMessage: lastMessage,
        lastMessageTime: DateTime.now(),
        itemImage: imageUrl,
      );

      _chatRooms.add(newChatRoom);
      notifyListeners();

      // 서버로 채팅방 정보 전송
      final url = Uri.parse('$baseUrl/chat/createRoom');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newChatRoom.toJson()),
        );

        if (response.statusCode != 201) {
          // 채팅방 생성 실패 시 추가된 채팅방을 목록에서 제거
          _chatRooms.removeWhere((chatRoom) => chatRoom.id == chatRoomId);
          notifyListeners();
          throw Exception('Failed to create chat room');
        }
      } catch (error) {
        // 오류 발생 시 추가된 채팅방을 목록에서 제거
        _chatRooms.removeWhere((chatRoom) => chatRoom.id == chatRoomId);
        notifyListeners();
        throw Exception('Failed to create chat room');
      }
    }
  }

  String _getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }
}