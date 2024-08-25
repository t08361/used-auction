// faq_page.dart
import 'package:flutter/material.dart';
class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
class FAQPage extends StatelessWidget {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: '질문 1: 이 앱은 무엇인가요?',
      answer: '답변: 이 앱은 중고 거래를 위한 플랫폼입니다.',
    ),
    FAQItem(
      question: '질문 2: 어떻게 회원가입을 하나요?',
      answer: '답변: 회원가입은 이메일과 비밀번호를 입력하여 간편하게 할 수 있습니다.',
    ),
    FAQItem(
      question: '질문 3: 아이템을 어떻게 등록하나요?',
      answer: '답변: 메인 화면에서 "아이템 등록" 버튼을 눌러 아이템을 등록할 수 있습니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          final item = faqItems[index];
          return ListTile(
            title: Text(item.question),
            subtitle: Text(item.answer),
          );
        },
      ),
    );
  }
}
