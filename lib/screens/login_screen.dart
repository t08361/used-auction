import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import 'signup_screen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final response = await loginUser(email, password);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        log('로그인 성공: ID = ${responseBody['id']}, 닉네임 = ${responseBody['nickname']}, 이메일 = ${responseBody['email']}');

        Provider.of<UserProvider>(context, listen: false).login();
        Provider.of<UserProvider>(context, listen: false).setUser(responseBody);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        _showErrorDialog(context, '아이디 또는 비밀번호가 틀렸습니다.');
      }
    } catch (error) {
      _showErrorDialog(context, '로그인 중 오류가 발생했습니다.');
    }
  }

  Future<http.Response> loginUser(String email, String password) {
    final url = Uri.parse('http://localhost:8080/api/users/login');
    return http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(),
                  ),
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}