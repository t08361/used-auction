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

// 로그인 화면 클래스
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
        log(
            '로그인 성공: ID = ${responseBody['id']}, 닉네임 = ${responseBody['nickname']}, 이메일 = ${responseBody['email']}');

        // UserProvider를 통해 로그인 상태 관리 및 사용자 정보 업데이트
        Provider.of<UserProvider>(context, listen: false).login();
        Provider.of<UserProvider>(context, listen: false).setUser(responseBody);

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
        backgroundColor: Colors.grey[850], // 배경색 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // 테두리 모서리 둥글게 설정
          side: BorderSide(color: Colors.red, width: 1), // 테두리 색상과 두께 설정
        ),
        title: Text(
          '오류',
          style: TextStyle(color: Colors.white), // 제목 색상 설정
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // 오류 메시지 색상 설정
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 확인 버튼 클릭 시 닫기
            },
            child: Text(
              '확인',
              style: TextStyle(color: Colors.red), // 버튼 텍스트 색상 설정
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,//Colors.grey[900], // 배경색 설정 (예: 다크 그레이)
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            const SizedBox(width: 20,),
            showOption
                ? GestureDetector(
              onTap: () {
                setState(() {
                  showOption = false;
                });
              },
              //child: const Icon(Icons.close, color: Colors.black, size: 30,),
            )
                : GestureDetector(
              onTap: () {
                setState(() {
                  showOption = true;
                });
              },
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
            //로그인창 테두리 색상
            border: Border.all(color: Colors.white60),
            borderRadius: BorderRadius.circular(15),
            // 로그인 창 그림자 색
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
                      Center(child: TextUtil(
                        text: "로그인", weight: true, size: 30,color: Colors.black, )),
                      const Spacer(),
                      TextUtil(text: "아이디",color: Colors.black,),
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
                      TextUtil(text: "비밀번호",color: Colors.black,),
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
                      Row(
                        // children: [
                        //   Container(
                        //     height: 15,
                        //     width: 15,
                        //     color: Colors.white,
                        //   ),
                        //   const SizedBox(width: 10,),
                        //   Expanded(
                        //       child: TextUtil(text: "Remember Me , FORGET PASSWORD", size: 12, weight: true,)
                        //   )
                        // ],
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
                          child: TextUtil(text: "로그인", color: Colors.white,),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // 회원가입 버튼 클릭 시 회원가입 화면으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: Center(child: TextUtil(
                          text: "회원가입", size: 16, weight: true,color: Colors.black,)),
                      ),
                      const Spacer(),
                    ],
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}