import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences를 위한 패키지 import

class UserProvider with ChangeNotifier {
  String _id = ''; // 사용자 ID를 저장하는 변수
  String _username = ''; // 사용자 이름을 저장하는 변수
  String _email = ''; // 사용자 이메일을 저장하는 변수
  String _nickname = ''; // 사용자 닉네임을 저장하는 변수
  String _location = ''; // 사용자 위치를 저장하는 변수
  int _age = 0; // 사용자 나이를 저장하는 변수

  // 각 변수에 대한 getter 정의
  String get id => _id;
  String get username => _username;
  String get email => _email;
  String get nickname => _nickname;
  String get location => _location;
  int get age => _age;

  bool _isLoggedIn = false; // 로그인 상태를 저장하는 변수

  bool get isLoggedIn => _isLoggedIn; // 로그인 상태에 대한 getter 정의

  // 사용자 정보를 설정하는 메서드
  void setUser(Map<String, dynamic> userData) async {
    _id = userData['id']; // 사용자 ID 설정
    _username = userData['username']; // 사용자 이름 설정
    _email = userData['email']; // 사용자 이메일 설정
    _nickname = userData['nickname']; // 사용자 닉네임 설정
    _location = userData['location']; // 사용자 위치 설정
    _age = userData['age']; // 사용자 나이 설정
    _isLoggedIn = true; // 로그인 상태로 설정
    notifyListeners(); // 상태 변경 알림

    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.setString('id', _id);
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    await prefs.setString('nickname', _nickname);
    await prefs.setString('location', _location);
    await prefs.setInt('age', _age);
    await prefs.setBool('isLoggedIn', true); // SharedPreferences에 로그인 상태 저장
  }

  // 사용자 정보를 초기화하는 메서드
  void clearUser() async {
    _id = ''; // 사용자 ID 초기화
    _username = ''; // 사용자 이름 초기화
    _email = ''; // 사용자 이메일 초기화
    _nickname = ''; // 사용자 닉네임 초기화
    _location = ''; // 사용자 위치 초기화
    _age = 0; // 사용자 나이 초기화
    _isLoggedIn = false; // 로그아웃 상태로 설정
    notifyListeners(); // 상태 변경 알림

    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.clear(); // SharedPreferences 초기화
  }

  // 로그인 상태를 로드하는 메서드
  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // SharedPreferences에서 로그인 상태 로드
    notifyListeners();
    if (_isLoggedIn) {
      _id = prefs.getString('id') ?? '';
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
      _nickname = prefs.getString('nickname') ?? '';
      _location = prefs.getString('location') ?? '';
      _age = prefs.getInt('age') ?? 0;
      notifyListeners();
    }
  }

  // 로그인 메서드
  void login() async {
    _isLoggedIn = true; // 로그인 상태로 설정
    notifyListeners(); // 상태 변경 알림
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.setBool('isLoggedIn', _isLoggedIn); // SharedPreferences에 로그인 상태 저장
  }

  // 로그아웃 메서드
  void logout() async {
    _isLoggedIn = false; // 로그아웃 상태로 설정
    notifyListeners(); // 상태 변경 알림
    SharedPreferences prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    await prefs.setBool('isLoggedIn', _isLoggedIn); // SharedPreferences에 로그아웃 상태 저장
  }
}