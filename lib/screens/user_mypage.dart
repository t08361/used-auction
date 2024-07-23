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

// 사용자 페이지를 나타내는 클래스 정의
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
      /*appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.black)), // 앱바 제목
        foregroundColor: Colors.black, backgroundColor: primary_color,
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상 설정
        ),
        elevation: 0,
      ),*/
      backgroundColor:background_color,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 설정
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                children: [
                  CircleAvatar(
                    radius: 45, // 원형 아바타의 반지름 설정
                    backgroundImage: userProvider.profileImage != null
                        ? NetworkImage(userProvider.profileImage!) as ImageProvider
                        : const AssetImage('assets/images/default_profile.png'), // 프로필 이미지 경로 설정
                  ),
                  const SizedBox(width: 20), // 간격 설정
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 시작점 기준 정렬
                    children: [
                      Text(
                        userProvider.nickname, // 닉네임 텍스트
                        style: const TextStyle(
                          fontSize: 20, // 폰트 크기 설정
                          fontWeight: FontWeight.bold, // 폰트 두께 설정
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        userProvider.email, // 이메일 텍스트
                        style: const TextStyle(
                          fontSize: 16, // 폰트 크기 설정
                          color: Colors.grey, // 폰트 색상 설정
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 100), // 간격 설정
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                 // leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text('내 정보', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _showMyStatus(context),
                //  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
             // const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                 // leading: const Icon(Icons.history, color: Colors.black),
                  title: const Text('판매내역', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _showSalesHistory(context),
                //  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
             // const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                 // leading: const Icon(Icons.shopping_cart, color: Colors.black),
                  title: const Text('구매내역', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _showPurchaseHistory(context),
                //  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
             // const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  //leading: const Icon(Icons.gavel, color: Colors.black),
                  title: const Text('진행중인 경매', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _ongoingauction(context),
                  //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
             // const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  //leading: const Icon(Icons.help_outline, color: Colors.black),
                  title: const Text('FAQ', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _showFAQ(context),
                  //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
            //  const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  //leading: const Icon(Icons.policy, color: Colors.black),
                  title: const Text('약관 및 정책', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _showTermsAndPolicies(context),
                  //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
              const SizedBox(height: 0),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                 // leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text('로그아웃', style: TextStyle(color: Colors.black)),
                  tileColor: button_color,
                  onTap: () => _logout(context),
                  //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
