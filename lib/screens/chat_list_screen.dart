import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chat-list';

  @override
  Widget build(BuildContext context) {
    // 예제 채팅 데이터
    final List<Map<String, String>> chatList = [
      {'name': 'Alice', 'lastMessage': 'Hi, how are you?'},
      {'name': 'Bob', 'lastMessage': 'Is the item still available?'},
      {'name': 'Charlie', 'lastMessage': 'Thanks for the update!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 목록'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return ListTile(
            title: Text(chat['name']!),
            subtitle: Text(chat['lastMessage']!),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatName: chat['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}