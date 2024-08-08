import 'dart:convert'; // JSON 인코딩 및 디코딩을 위한 라이브러리
import 'dart:developer'; // 디버깅을 위한 라이브러리
import 'package:flutter/material.dart'; // Flutter UI 프레임워크
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import '../main.dart'; // MainScreen 클래스를 가져오기 위해 import
import '../providers/constants.dart'; // baseUrl 등 상수를 가져오기 위해 import
import '../providers/user_provider.dart'; // UserProvider 클래스를 가져오기 위해 import
import 'signup_screen.dart'; // SignupScreen 클래스를 가져오기 위해 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리

// 로그인 화면 클래스
class LoginScreen extends StatelessWidget {
  static const routeName = '/login'; // 라우트 이름 정의

  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 필드 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 필드 컨트롤러

  // 로그인 버튼 클릭 시 실행되는 함수
  void _login(BuildContext context) async {
    final email = _emailController.text; // 입력받은 이메일
    final password = _passwordController.text; // 입력받은 패스워드

    // 이메일 또는 비밀번호가 비어있을 경우 오류 출력
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      // 로그인 요청을 보내고 응답을 받음
      final response = await loginUser(email, password);
      if (response.statusCode == 200) {
        // 로그인 성공 시 응답 본문을 디코딩
        final responseBody = json.decode(response.body);

        // 디버깅을 위해 로그인 성공 로그 출력
        log('로그인 성공: ID = ${responseBody['id']}, 닉네임 = ${responseBody['nickname']}, 이메일 = ${responseBody['email']}');


        Provider.of<UserProvider>(context, listen: false).login();//userprovider의 login함수를 호출하여 로그인 상태관리
        Provider.of<UserProvider>(context, listen: false).setUser(responseBody);//userprovider의 setUser함수를 호출하여 사용자 정보 업데이트

        // 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        // 로그인 실패 시 오류 출력
        _showErrorDialog(context, '아이디 또는 비밀번호가 틀렸습니다.');
      }
    } catch (error) {
      // 예외 발생 시 오류 출력
      _showErrorDialog(context, '로그인 중 오류가 발생했습니다.');
    }
  }

  // 사용자 로그인 요청을 보내는 메서드
  Future<http.Response> loginUser(String email, String password) {
    final url = Uri.parse('$baseUrl/users/login'); // 로그인 URL 설정
    return http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // JSON 형식 헤더 설정
      },
      body: jsonEncode(<String, String>{ // 요청 본문 설정
        'email': email,
        'password': password,
      }),
    );
  }

  // 오류 호출하는 함수
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('오류'),
        content: Text(message), // 오류 메세지
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 확인 버튼 클릭 시 닫기
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
        title: Text('로그인'), // 앱바 제목
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController, // 이메일 입력 필드
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController, // 비밀번호 입력 필드
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true, // 비밀번호 숨김 설정
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context), // 로그인 버튼 클릭 시 _login 함수 호출
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 버튼 클릭 시 회원가입 화면으로 이동
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
