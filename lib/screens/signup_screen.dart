import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  File? _selectedImage;

  Future<void> _signup(BuildContext context) async {
    final id = _idController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final nickname = _nicknameController.text;
    final email = _emailController.text;
    final location = _locationController.text;
    final age = int.tryParse(_ageController.text);

    if (password != confirmPassword) {
      print("Passwords do not match");
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/users');

    var request = http.MultipartRequest('POST', url)
      ..fields['user'] = json.encode({
        'username': id,
        'password': password,
        'nickname': nickname,
        'email': email,
        'location': location,
        'age': age,
      });

    // 이미지 선택되었으면 이미지도 전송
    if (_selectedImage != null) {
      print('이미지가 선택됨');
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        _selectedImage!.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      print('회원가입 성공!');
      Navigator.of(context).pop();
    } else {
      final responseBody = await response.stream.bytesToString();
      print('회원가입 실패');
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
    }


  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                    ? Icon(Icons.add_a_photo, size: 40,)
                      : null,
                ),
              ),
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: '아이디'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: '비밀번호 확인'),
                obscureText: true,
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: '닉네임'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: '거주지역'),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signup(context),
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}