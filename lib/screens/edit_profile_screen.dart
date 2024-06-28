import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
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
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            SizedBox(height: 20),
            Text(
              '나의 매너등급',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: _mannerScore / 10, // 1~10 범위를 0.0~1.0 범위로 변환
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
            SizedBox(height: 10),
            Text(
              '등급: $_mannerScore/10',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveProfile(context),
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
