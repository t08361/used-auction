import 'package:flutter/material.dart';

import 'signup_screen.dart';
import 'social_login_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) {
    // 로그인 처리 로직
    // 예를 들어, 서버에 요청을 보내고 응답을 처리합니다.
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.of(context).pushNamed('/signup');
  }

  void _navigateToSocialLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/social-login');
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
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SocialLoginScreen(),
                  ),
                );
              },
              child: Text('간편 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}