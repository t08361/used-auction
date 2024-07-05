// LoginScreen 페이지
// 이 페이지는 사용자가 이메일과 비밀번호로 로그인할 수 있는 화면을 제공합니다.
// 로그인 요청을 서버에 보내고, 성공 시 사용자 정보를 UserProvider에 설정하고 메인 화면으로 이동합니다.
// 실패 시에는 오류 메시지를 다이얼로그로 표시합니다.

import 'dart:convert'; // JSON 변환을 위한 패키지 import
import 'dart:developer'; // 로그 출력을 위한 패키지 import
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위해 Provider 패키지를 import
import '../main.dart'; // 메인 화면 import
import '../providers/user_provider.dart'; // UserProvider import
import 'user_mypage.dart'; // UserPage 화면 import
import 'signup_screen.dart'; // 회원가입 화면 import
import 'social_login_screen.dart'; // 소셜 로그인 화면 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지 import

class LoginScreen extends StatelessWidget {
  static const routeName = '/login'; // 로그인 화면의 라우트 이름 정의

  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러

  // 로그인 요청을 서버에 보내는 메서드
  void _login(BuildContext context) async {
    final email = _emailController.text; // 이메일 입력 값
    final password = _passwordController.text; // 비밀번호 입력 값

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, '이메일과 비밀번호를 입력해주세요.'); // 이메일 또는 비밀번호가 비어있으면 오류 메시지 표시
      return;
    }

    try {
      final response = await loginUser(email, password); // 로그인 요청 보내기
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body); // 응답 본문을 JSON으로 변환

        // 로그에 사용자 정보 출력
        log('로그인 성공: ID = ${responseBody['id']}, 닉네임 = ${responseBody['nickname']}, 이메일 = ${responseBody['email']}');

        // UserProvider에 사용자 정보 설정
        Provider.of<UserProvider>(context, listen: false).setUser(responseBody);

        // 로그인 상태 설정
        Provider.of<UserProvider>(context, listen: false).login();

        // MainScreen으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(), // 로그인 성공 후 MainScreen으로 이동
          ),
        );
      } else {
        _showErrorDialog(context, '아이디 또는 비밀번호가 틀렸습니다.'); // 로그인 실패 시 오류 메시지 표시
      }
    } catch (error) {
      _showErrorDialog(context, '로그인 중 오류가 발생했습니다.'); // 로그인 중 오류 발생 시 메시지 표시
    }
  }

  // 서버에 로그인 요청을 보내는 메서드
  Future<http.Response> loginUser(String email, String password) {
    final url = Uri.parse('http://localhost:8080/api/users/login'); // 서버 URL
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

  // 오류 메시지를 다이얼로그로 표시하는 메서드
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('오류'), // 다이얼로그 타이틀
        content: Text(message), // 다이얼로그 메시지
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 확인 버튼 클릭 시 다이얼로그 닫기
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  // 회원가입 화면으로 이동하는 메서드
  void _navigateToSignup(BuildContext context) {
    Navigator.of(context).pushNamed(SignupScreen.routeName);
  }

  // 소셜 로그인 화면으로 이동하는 메서드
  void _navigateToSocialLogin(BuildContext context) {
    Navigator.of(context).pushNamed(SocialLoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'), // 앱바 타이틀 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 설정
        child: Column(
          children: [
            TextField(
              controller: _emailController, // 이메일 입력 컨트롤러
              decoration: InputDecoration(labelText: '이메일'), // 이메일 입력 필드의 힌트 텍스트
            ),
            TextField(
              controller: _passwordController, // 비밀번호 입력 컨트롤러
              decoration: InputDecoration(labelText: '비밀번호'), // 비밀번호 입력 필드의 힌트 텍스트
              obscureText: true, // 비밀번호 입력 필드의 텍스트 숨김 설정
            ),
            SizedBox(height: 20), // 간격 추가
            ElevatedButton(
              onPressed: () => _login(context), // 로그인 버튼 클릭 시 _login 메서드 호출
              child: Text('로그인'), // 버튼 텍스트
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignupScreen(), // 회원가입 화면으로 이동
                  ),
                );
              },
              child: Text('회원가입'), // 회원가입 버튼 텍스트
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SocialLoginScreen(), // 소셜 로그인 화면으로 이동
                  ),
                );
              },
              child: Text('간편 로그인'), // 간편 로그인 버튼 텍스트
            ),
          ],
        ),
      ),
    );
  }
}