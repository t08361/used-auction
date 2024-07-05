import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/constants.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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

    final url = Uri.parse('$baseUrl/users');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': id,
        'password': password,
        'nickname': nickname,
        'email': email,
        'location': location,
        'age': age,
      }),
    );

    if (response.statusCode == 201) {
      print('User added successfully');
      Navigator.of(context).pop();
    } else {
      print('Failed to add user');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
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