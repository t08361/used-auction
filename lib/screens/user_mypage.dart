import 'dart:convert';

import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // Provider 패키지 import
import '../providers/user_provider.dart'; // UserProvider import
import 'ongoing_auction_screen.dart'; // 진행중인 경매 화면 import
import 'edit_profile_screen.dart'; // 프로필 수정 화면 import
import 'sales_history_screen.dart'; // 판매 내역 화면 import
import 'purchase_history_screen.dart'; // 구매 내역 화면 import
import 'FAQ_screen.dart'; // FAQ 화면 import
import 'terms_and_policies_screen.dart'; // 약관 및 정책 화면 import
import '../providers/constants.dart';

class UserPage extends StatelessWidget {
  // UserPage 라우트 이름 정의
  static const routeName = '/social-signup';

  // 사용자 입력을 받기 위한 컨트롤러들 생성
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 내 정보 수정 페이지로 이동하는 함수
  void _showMyStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()), // EditProfilePage로 이동
    );
  }

  // 진행중인 경매 페이지로 이동하는 함수
  void _ongoingauction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuctionPage()), // AuctionPage로 이동
    );
  }

  // 판매 내역 페이지로 이동하는 함수
  void _showSalesHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaleHistoryPage()), // SaleHistoryPage로 이동
    );
  }

  // 구매 내역 페이지로 이동하는 함수
  void _showPurchaseHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PurchaseHistoryPage()), // PurchaseHistoryPage로 이동
    );
  }

  // FAQ 페이지로 이동하는 함수
  void _showFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQPage()), // FAQPage로 이동
    );
  }

  // 약관 및 정책 페이지로 이동하는 함수
  void _showTermsAndPolicies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndPoliciesPage()), // TermsAndPoliciesPage로 이동
    );
  }

  // 로그아웃 함수
  void _logout(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).logout(); // UserProvider의 logout 메서드 호출
    Navigator.of(context).pushReplacementNamed('/homescreen'); // 로그인 화면으로 이동
  }

  // 사용자 페이지의 UI 빌드
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      //backgroundColor: background_color,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '마이 페이지',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: userProvider.profileImage != null

                        ? NetworkImage(userProvider.profileImage!) as ImageProvider
                        : const AssetImage('assets/images/default_profile.png'), // 프로필 이미지 경로 설정
                  ),
                  const SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProvider.nickname,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        userProvider.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Text(
                      '나의 거래',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTradeButton(
                          context,
                          '판매내역',
                          Icons.history,
                          _showSalesHistory,
                        ),
                        _buildTradeButton(
                          context,
                          '구매내역',
                          Icons.shopping_cart,
                          _showPurchaseHistory,
                        ),
                        _buildTradeButton(
                          context,
                          '진행중인 경매',
                          Icons.gavel,
                          _ongoingauction,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Card(

                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.black),
                        title: Text('내 정보', style: TextStyle(color: Colors.black)),
                     //   tileColor: button_color,
                        onTap: () => _showMyStatus(context),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.help_outline, color: Colors.black),
                        title: Text('FAQ', style: TextStyle(color: Colors.black)),
                      //  tileColor: button_color,
                        onTap: () => _showFAQ(context),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.policy, color: Colors.black),
                        title: Text('약관 및 정책', style: TextStyle(color: Colors.black)),
                     //   tileColor: button_color,
                        onTap: () => _showTermsAndPolicies(context),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.black),
                        title: Text('로그아웃', style: TextStyle(color: Colors.black)),
                     //   tileColor: button_color,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeButton(BuildContext context, String text, IconData icon, Function(BuildContext) onTap) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: button_color,
              borderRadius: BorderRadius.circular(12),
            ),
            width: 80,
            height: 80,
            child: Icon(icon, size: 40, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
