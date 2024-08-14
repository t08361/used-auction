import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img; // 이미지 처리 패키지

import '../providers/constants.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  static const routeName = '/edit-profile';

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
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

  Future<File> _optimizeImage(File imageFile) async {
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) {
      throw Exception("이미지 디코딩에 실패했습니다.");
    }

    final resizedImage = img.copyResize(image, width: 300);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 70);

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedImageBytes);

    return tempFile;
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final optimizedImage = await _optimizeImage(image);

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/${optimizedImage.path.split('/').last}');
      await imageRef.putFile(optimizedImage);
      final imageUrl = await imageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<void> _updateProfileImage(BuildContext context) async {
    if (_profileImage != null) {
      final imageUrl = await _uploadImageToFirebase(_profileImage!);

      if (imageUrl != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final id = userProvider.id;

        final response = await http.patch(
          Uri.parse('$baseUrl/users/$id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'profileImage': imageUrl}),
        );

        if (response.statusCode == 200) {
          // 프로필 이미지 업데이트
          userProvider.setUser({
            'id': id,
            'username': userProvider.username,
            'email': userProvider.email,
            'nickname': userProvider.nickname,
            'location': userProvider.location,
            'age': userProvider.age,
            'profileImage': imageUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필 이미지가 수정되었습니다.')),
          );
        } else {
          print('프로필 이미지 수정 실패: ${response.statusCode}');
        }
      }
    } else {
      print('선택된 이미지가 없습니다.');
    }
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

  void _withdrawal(BuildContext context) async {
    final id = Provider.of<UserProvider>(context, listen: false).id;

    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 204) { // 서버가 성공적으로 삭제한 경우
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탈퇴가 완료되었습니다.')),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        print('탈퇴 중 서버에서 오류 발생');
      }
    } catch (e) {
      print('탈퇴 중 예외 발생');
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
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _updateProfileImage(context);
              },
              child: const Text('이미지 수정'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '닉네임'),
                  ),
                ),
                const SizedBox(width: 10), // 버튼과 텍스트 필드 사이의 간격
                ElevatedButton(
                  onPressed: () async {
                    final newNickname = _nameController.text;
                    if (newNickname.isNotEmpty) {
                      await Provider.of<UserProvider>(context, listen: false).updateNickname(newNickname);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('닉네임이 수정되었습니다.')),
                      );
                    }
                  },
                  child: const Text('닉네임 수정'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '나의 매너등급',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _mannerScore / 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              '등급: $_mannerScore/10',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _showWithdrawalConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                '탈퇴하기',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}