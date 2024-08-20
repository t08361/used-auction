import 'package:flutter/material.dart'; // 플러터의 UI 라이브러리
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리
import 'dart:convert'; // JSON 변환을 위한 다트 라이브러리
import '../models/user.dart'; // 사용자 모델을 불러옴
import 'constants.dart'; // 상수 값을 불러옴

// ChangeNotifier를 믹스인으로 사용하여 상태 변경을 관리하는 UserProvider 클래스 정의
class UserProvider with ChangeNotifier {
  List<User> _users = []; // 사용자 목록을 저장하는 리스트

  // 사용자 정보 변수 정의
  String _id = ''; // 사용자 ID를 저장하는 변수
  String _username = ''; // 사용자 이름을 저장하는 변수
  String _email = ''; // 사용자 이메일을 저장하는 변수
  String _nickname = ''; // 사용자 닉네임을 저장하는 변수
  String _location = ''; // 사용자 위치를 저장하는 변수
  int _age = 0; // 사용자 나이를 저장하는 변수
  String? _profileImage; // 프로필 이미지를 저장하는 변수
  String? _token; // JWT 토큰 저장 변수

  // 각 변수에 대한 getter 정의
  String get id => _id;
  String get username => _username;
  String get email => _email;
  String get nickname => _nickname;
  String get location => _location;
  int get age => _age;
  String? get profileImage => _profileImage; // 프로필 이미지 getter
  bool _isLoggedIn = false; // 로그인 상태를 저장하는 변수
  bool get isLoggedIn => _isLoggedIn; // 로그인 상태에 대한 getter 정의
  String? get token => _token; // 토큰에 대한 getter 정의

  // 특정 ID로 사용자 닉네임을 가져오는 메서드
  String getNicknameById(String id) {
    // 주어진 ID에 해당하는 사용자를 찾고 닉네임을 반환
    final user = _users.firstWhere(
          (user) => user.id == id,
      orElse: () => User(
        id: '',
        username: '',
        password: '',
        nickname: 'Unknown',
        email: '',
        location: '',
        age: 0,
        profileImage: '',
      ),
    );
    return user.nickname;
  }

  // 사용자 정보를 설정하는 메서드
  void setUser(Map<String, dynamic> userData) async {
    _id = userData['id']; // 사용자 ID 설정
    _username = userData['username']; // 사용자 이름 설정
    _email = userData['email']; // 사용자 이메일 설정
    _nickname = userData['nickname']; // 사용자 닉네임 설정
    _location = userData['location']; // 사용자 위치 설정
    _age = userData['age']; // 사용자 나이 설정
    _profileImage = userData['profileImage']; // 프로필 이미지 설정
    _isLoggedIn = true; // 로그인 상태로 설정
    _token = userData['token']; // JWT 토큰 설정
    notifyListeners(); // 상태 변경 알림

    // SharedPreferences 인스턴스 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 사용자 정보를 SharedPreferences에 저장
    await prefs.setString('id', _id);
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    await prefs.setString('nickname', _nickname);
    await prefs.setString('location', _location);
    await prefs.setInt('age', _age);
    if (_profileImage != null) {
      await prefs.setString('profileImage', _profileImage!); // 프로필 이미지 저장
    }
    await prefs.setBool('isLoggedIn', true); // SharedPreferences에 로그인 상태 저장
    await prefs.setString('token', _token!); // JWT 토큰 저장
  }

  // 사용자 정보를 초기화하는 메서드
  void clearUser() async {
    _id = ''; // 사용자 ID 초기화
    _username = ''; // 사용자 이름 초기화
    _email = ''; // 사용자 이메일 초기화
    _nickname = ''; // 사용자 닉네임 초기화
    _location = ''; // 사용자 위치 초기화
    _age = 0; // 사용자 나이 초기화
    _profileImage = null; // 프로필 이미지 초기화
    _isLoggedIn = false; // 로그아웃 상태로 설정
    _token = null; // 토큰 초기화
    notifyListeners(); // 상태 변경 알림

    // SharedPreferences 인스턴스 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // SharedPreferences 초기화
  }

  // 로그인 상태를 로드하는 메서드
  Future<void> loadUser() async {
    // SharedPreferences 인스턴스 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // SharedPreferences에서 로그인 상태 로드
    notifyListeners(); // 상태 변경 알림
    if (_isLoggedIn) {
      // SharedPreferences에서 사용자 정보 로드
      _id = prefs.getString('id') ?? '';
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
      _nickname = prefs.getString('nickname') ?? '';
      _location = prefs.getString('location') ?? '';
      _age = prefs.getInt('age') ?? 0;
      _profileImage = prefs.getString('profileImage'); // 프로필 이미지 로드
      _token = prefs.getString('token'); // JWT 토큰 로드
      notifyListeners(); // 상태 변경 알림
    }
  }

  // 로그인 메서드
  void login() async {
    _isLoggedIn = true; // 로그인 상태로 설정
    notifyListeners(); // 상태 변경 알림

    // SharedPreferences 인스턴스 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', _isLoggedIn); // SharedPreferences에 로그인 상태 저장
  }

  // 로그아웃 메서드
  void logout() async {
    _isLoggedIn = false; // 로그아웃 상태로 설정
    _profileImage = null; // 프로필 이미지 초기화
    _token = null; // 토큰 초기화
    notifyListeners(); // 상태 변경 알림

    // SharedPreferences 인스턴스 가져오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', _isLoggedIn); // SharedPreferences에 로그아웃 상태 저장
    await prefs.remove('token'); // 저장된 JWT 토큰 삭제
  }

  // 특정 아이디로 사용자 정보를 가져와 프로필 이미지를 반환하는 메서드
  Future<String?> getProfileImageById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id')); // HTTP GET 요청
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // 응답 데이터를 JSON으로 변환
        print(data['profileImage']); // 프로필 이미지 출력
        return data['profileImage']; // 프로필 이미지 반환
      } else {
        print('유저 탈퇴함'); // 오류 메시지 출력
        return null;
      }
    } catch (e) {
      print('Error fetching profile image: $e'); // 예외 메시지 출력
      return null;
    }
  }

  // 특정 아이디로 사용자가 존재하는지 확인하는 메서드
  Future<bool> doesUserExist(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id')); // HTTP GET 요청
      if (response.statusCode == 200) {
        return true; // 사용자가 존재함
      } else if (response.statusCode == 404) {
        return false; // 사용자가 존재하지 않음
      } else {
        print('상대 유저 탈퇴 체크 중 오류'); // 오류 메시지 출력
        return false;
      }
    } catch (e) {
      print('상대 유저 탈퇴 체크 중 예외: $e'); // 예외 메시지 출력
      return false;
    }
  }

  // 닉네임 수정 메서드
  Future<void> updateNickname(String newNickname) async {
    final id = _id; // 현재 사용자 ID
    if (id.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$id'), // 사용자 ID를 이용해 PATCH 요청
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nickname': newNickname}),
      );

      if (response.statusCode == 200) {
        // 서버에서 성공적으로 업데이트한 경우
        _nickname = newNickname;
        notifyListeners(); // 상태 변경 알림
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nickname', newNickname); // SharedPreferences에 닉네임 저장
      } else {
        print('닉네임 수정 실패');
      }
    } catch (e) {
      print('닉네임 수정 중 오류 발생: $e');
    }
  }


}
