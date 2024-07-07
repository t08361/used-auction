import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chat-list';

  @override
  Widget build(BuildContext context) {
    // 예제 채팅 데이터
    final List<Map<String, String>> chatList = [
      {
        'name': '김정만',
        'lastMessage': '쿨거래 감사합니다.',
        'bidPrice': '10,000원',
        'image': 'assets/images/alice.png'
      },
      {
        'name': '김치국',
        'lastMessage': '거래 감사합니다! 거래완료 한번 눌러주세요~',
        'bidPrice': '20,000원',
        'image': 'assets/images/bob.png'
      },
      {
        'name': '김사발',
        'lastMessage': '직거래 어디서 가능하실까요?',
        'bidPrice': '30,000원',
        'image': 'assets/images/charlie.png'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(chat['image']!),
                ),
                SizedBox(width: 10), // 이미지와 텍스트 사이의 간격
                Expanded(
                  child: ListTile(
                    title: Text(chat['name']!),
                    subtitle: Text(chat['lastMessage']!),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatName: 'Chat Room',
                            bidPrice: '10000',
                            image: 'assets/profile.png',
                            channel: IOWebSocketChannel.connect('ws://localhost:8080/ws'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  '낙찰가 : '+chat['bidPrice']!, // 각 항목에 다른 텍스트를 표시
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}