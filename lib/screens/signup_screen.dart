import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../providers/constants.dart';

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
  String _passwordError = '';

  @override
  void initState() {
    super.initState();
    _confirmPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _confirmPasswordController.removeListener(_validatePassword);
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = '비밀번호가 일치하지 않습니다.';
      } else {
        _passwordError = '';
      }
    });
  }

  Future<void> _signup(BuildContext context) async {
    final id = _idController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final nickname = _nicknameController.text;
    final email = _emailController.text;
    final location = _locationController.text;
    final age = int.tryParse(_ageController.text);

    // 필수 입력 필드 검증
    if (id.isEmpty || password.isEmpty || nickname.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('입력 오류'),
            content: Text('아이디, 비밀번호, 닉네임은 필수 입력 항목입니다.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('입력 오류'),
            content: Text('비밀번호가 일치하지 않습니다.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final url = Uri.parse('$baseUrl/users');

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
    Navigator.of(context).pop();

    if (response.statusCode == 201) {
      print('회원가입 성공!');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('회원가입 완료'),
            content: Text('회원가입이 완료되었습니다! 로그인해주세요.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
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
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 40,
                        )
                      : null,
                ),
              ),
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: '아이디 *'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 *',
                ),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인 *',
                  errorText: _passwordError.isEmpty ? null : _passwordError,
                ),
                obscureText: true,
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: '닉네임 *'),
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
