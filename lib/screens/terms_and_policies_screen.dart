// terms_and_policies_page.dart
import 'package:flutter/material.dart';

class TermsAndPoliciesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약관 및 정책'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서비스 이용 약관',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '여기에 서비스 이용 약관 내용을 입력하세요. 이 앱을 사용함으로써 동의하는 조건들에 대한 상세한 설명입니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                '개인정보 보호 정책',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '여기에 개인정보 보호 정책 내용을 입력하세요. 사용자의 개인정보를 어떻게 수집하고 사용하는지에 대한 설명입니다.',
                style: TextStyle(fontSize: 16),
              ),
              // 필요한 경우 더 많은 섹션 추가
            ],
          ),
        ),
      ),
    );
  }
}
