import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/constants.dart';
import '../providers/user_provider.dart'; // HTTP 요청을 위한 라이브러리

class EditProfilePage extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  double _mannerScore = 7.5; // 매너등급 (1~10)

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  void _saveProfile(BuildContext context) {
    // 프로필 저장 로직
    // 예를 들어, 서버에 요청을 보내고 응답을 처리합니다.
  }

  void _showWithdrawalConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('탈퇴 확인'),
        content: const Text('정말로 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 다이얼로그 닫기
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // 다이얼로그 닫기
              _withdrawal(context); // 탈퇴 기능 실행
            },
            child: const Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 회원 탈퇴기능
  void _withdrawal(BuildContext context) async {
    // UserProvider에서 현재 사용자의 ID를 가져오기
    final id = Provider.of<UserProvider>(context, listen: false).id;

    try {
      // 서버에 DELETE 요청 보내기
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 204) { // 서버가 성공적으로 삭제한 경우
        // 사용자 정보 초기화 및 로그아웃 처리
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearUser();

        // 성공 메시지를 사용자에게 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탈퇴가 완료되었습니다.')),
        );

        // 로그인 페이지로 이동 또는 홈 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        print('탈퇴중 서버에서 오류 발생');
      }
    } catch (e) {
      print('탈퇴중 예외 발생');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : AssetImage('assets/profile.jpg') as ImageProvider,
                child: _profileImage == null ? Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '닉네임'),
            ),
            const SizedBox(height: 20),
            const Text(
              '나의 매너등급',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _mannerScore / 10, // 1~10 범위를 0.0~1.0 범위로 변환
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '등급: $_mannerScore/10',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveProfile(context),
              child: const Text('저장'),
            ),
            const Spacer(), // 여백을 추가해서 회원탈퇴 버튼 아래로 밀기
            ElevatedButton(
              onPressed: () => _showWithdrawalConfirmation(context), // 회원 탈퇴 확인 다이얼로그 표시
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 빨간버튼
              ),
              child: const Text(
                '탈퇴하기',
                style: TextStyle(color: Colors.white), // 하얀글씨
              ),
            ),
            const SizedBox(height: 20), // 아래 여백
          ],
        ),
      ),
    );
  }
}
