import 'package:flutter/material.dart';

class SocialLoginScreen extends StatelessWidget {
  static const routeName = '/social-login';

  void _loginWithGoogle(BuildContext context) {
    // Google 로그인 처리 로직
  }

  void _loginWithFacebook(BuildContext context) {
    // Facebook 로그인 처리 로직
  }

  void _navigateToSocialSignup(BuildContext context) {
    Navigator.of(context).pushNamed('/social-signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('간편 로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _loginWithGoogle(context),
              child: Text('Google 로그인'),
            ),
            ElevatedButton(
              onPressed: () => _loginWithFacebook(context),
              child: Text('Facebook 로그인'),
            ),
            TextButton(
              onPressed: () => _navigateToSocialSignup(context),
              child: Text('간편 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}