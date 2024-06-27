import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  static const routeName = '/social-signup';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _signup(BuildContext context) {
    // 간편 회원가입 처리 로직
    // 예를 들어, 서버에 요청을 보내고 응답을 처리합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '판매내역'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '구매내역'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signup(context),
              child: Text('진행중인 경매'),
            ),
          ],
        ),
      ),
    );
  }
}