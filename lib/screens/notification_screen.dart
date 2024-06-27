import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    // 예제 알림 데이터
    final List<String> notifications = [
      '알림 1: 새로운 메시지가 도착했습니다.',
      '알림 2: 아이템이 판매되었습니다.',
      '알림 3: 새로운 댓글이 달렸습니다.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notifications[index]),
            onTap: () {
              // 알림 세부 정보 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(
                    notification: notifications[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final String notification;

  NotificationDetailScreen({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 세부 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          notification,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}