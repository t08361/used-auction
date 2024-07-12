import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chatMessage.dart';
import '../models/chatRoom.dart';

class ChatProvider with ChangeNotifier {
  final String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  List<ChatMessage> _messages = [];
  List<ChatRoom> _chatRooms = [];

  List<ChatMessage> get messages => _messages;
  List<ChatRoom> get chatRooms => _chatRooms;

  Future<void> loadMessages(String chatRoomId) async {
    final url = Uri.parse('$baseUrl/api/chat/messages/$chatRoomId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        final List<ChatMessage> loadedMessages = [];
        for (var messageData in extractedData) {
          loadedMessages.add(ChatMessage.fromJson(messageData));
        }
        _messages = loadedMessages;
        notifyListeners();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (error) {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(String chatRoomId, String senderId, String recipientId, String content, DateTime timestamp) async {
    final url = Uri.parse('$baseUrl/api/chat/sendMessage');
    final messageData = {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageData),
      );
      if (response.statusCode == 201) {
        _messages.add(ChatMessage.fromJson(json.decode(response.body)));
        notifyListeners();
      } else {
        throw Exception('Failed to send message');
      }
    } catch (error) {
      throw Exception('Fail to send message');
    }
  }

  void createChatRoom(String senderId,String sellerNickname, String recipientId,String buyerNickname, String lastMessage, String imageUrl) {
    final chatRoomId = _getChatRoomId(senderId, recipientId);
    final existingChat = _chatRooms.any((chatRoom) => chatRoom.id == chatRoomId);
    if (!existingChat) {
      _chatRooms.add(ChatRoom(
        id: chatRoomId,
        sellerId: senderId,
        sellerNickname: sellerNickname,
        buyerId: recipientId,
        buyerNickname: buyerNickname,
        finalPrice: 0,
        lastMessage: lastMessage,
        lastMessageTime: DateTime.now(),
        itemImage: imageUrl,
      ));
      notifyListeners();
    }
  }

  String _getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }
}