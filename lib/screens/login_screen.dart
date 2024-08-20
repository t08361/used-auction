import 'dart:convert'; // JSON 인코딩 및 디코딩을 위한 라이브러리
import 'dart:developer'; // 디버깅을 위한 라이브러리
import 'dart:ui'; // 블러 효과를 위한 라이브러리

import 'package:flutter/material.dart'; // Flutter UI 프레임워크
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import '../main.dart'; // MainScreen 클래스를 가져오기 위해 import
import '../providers/constants.dart'; // baseUrl 등 상수를 가져오기 위해 import
import '../providers/user_provider.dart'; // UserProvider 클래스를 가져오기 위해 import
import 'signup_screen.dart'; // SignupScreen 클래스를 가져오기 위해 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리

import '../widgets/animations.dart'; // 애니메이션을 위한 위젯 import
import '../widgets/text_utils.dart'; // 텍스트 유틸리티 위젯 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 필드 컨트롤러
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 필드 컨트롤러

  int selectedIndex = 0;
  bool showOption = false;

  void _login(BuildContext context) async {
    final email = _emailController.text; // 입력받은 이메일
    final password = _passwordController.text; // 입력받은 패스워드

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final response = await loginUser(email, password);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // JSON에서 user 객체 안의 값을 가져오기
        final user = responseBody['user'];
        log('로그인 성공: ID = ${user['id']}, 닉네임 = ${user['nickname']}, 이메일 = ${user['email']}');

        Provider.of<UserProvider>(context, listen: false).login();
        Provider.of<UserProvider>(context, listen: false).setUser(user);

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
    final url = Uri.parse('$baseUrl/users/login');
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
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.red, width: 1),
        ),
        title: const Text(
          '오류',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height:49,
        width: double.infinity,
        child: Row(
          children: [
            const SizedBox(width: 20,),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showOption = !showOption;
                  });
                },
                child: Icon(
                  showOption ? Icons.close : Icons.menu,
                  color: Colors.black,
                  size: 0,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 0, sigmaX: 0),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const Center(
                      child: Text(
                        "로그인",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.w400, // 가벼운 두께로 설정
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "아이디",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400, // 가벼운 두께로 설정
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(
                              color: Colors.black))
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.mail, color: Colors.black,),
                          fillColor: Colors.black,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "비밀번호",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400, // 가벼운 두께로 설정
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(
                              color: Colors.black))
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.lock, color: Colors.black,),
                          fillColor: Colors.black,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _login(context),
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30)
                        ),
                        alignment: Alignment.center,
                        child: const Center(
                          child: Text(
                            "로그인",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // 기존에 true로 설정되어 있던 부분을 bold로 대체
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: const Center(
                        child: Center(
                          child: Text(
                            "회원가입",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // 기존에 true로 설정되어 있던 부분을 bold로 대체
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
