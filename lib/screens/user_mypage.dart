import 'dart:convert';
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // Provider 패키지 import
import '../providers/user_provider.dart'; // UserProvider import (사용자 데이터를 관리하는 Provider)
import 'ongoing_auction_screen.dart'; // 진행 중인 경매 화면 import
import 'edit_profile_screen.dart'; // 프로필 수정 화면 import
import 'sales_history_screen.dart'; // 판매 내역 화면 import
import 'purchase_history_screen.dart'; // 구매 내역 화면 import
import 'FAQ_screen.dart'; // FAQ 화면 import
import 'terms_and_policies_screen.dart'; // 약관 및 정책 화면 import
import '../providers/constants.dart'; // 앱 내 상수값들을 모아둔 파일 import

// UserPage 클래스 정의 (마이 페이지를 나타내는 StatelessWidget)
class UserPage extends StatelessWidget {
  // UserPage 라우트 이름 정의 (라우팅 시 사용될 이름)
  static const routeName = '/social-signup';

  // 사용자 입력을 받기 위한 컨트롤러들 생성 (사용자 이름과 이메일을 입력받기 위한 TextEditingController)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 내 정보 수정 페이지로 이동하는 함수 (Navigator를 사용하여 EditProfilePage로 이동)
  void _showMyStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()), // EditProfilePage로 이동
    );
  }

  // 진행 중인 경매 페이지로 이동하는 함수 (Navigator를 사용하여 AuctionPage로 이동)
  void _ongoingauction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AuctionPage()), // AuctionPage로 이동
    );
  }

  // 판매 내역 페이지로 이동하는 함수 (Navigator를 사용하여 SaleHistoryPage로 이동)
  void _showSalesHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaleHistoryPage()), // SaleHistoryPage로 이동
    );
  }

  // 구매 내역 페이지로 이동하는 함수 (Navigator를 사용하여 PurchaseHistoryPage로 이동)
  void _showPurchaseHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PurchaseHistoryPage()), // PurchaseHistoryPage로 이동
    );
  }

  // FAQ 페이지로 이동하는 함수 (Navigator를 사용하여 FAQPage로 이동)
  void _showFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FAQPage()), // FAQPage로 이동
    );
  }

  // 약관 및 정책 페이지로 이동하는 함수 (Navigator를 사용하여 TermsAndPoliciesPage로 이동)
  void _showTermsAndPolicies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndPoliciesPage()), // TermsAndPoliciesPage로 이동
    );
  }

  // 로그아웃 함수 (UserProvider의 logout 메서드를 호출하고 로그인 화면으로 이동)
  void _logout(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).logout(); // UserProvider의 logout 메서드 호출
    Navigator.of(context).pushReplacementNamed('/homescreen'); // 로그인 화면으로 이동
  }

  // 사용자 페이지의 UI 빌드
  @override
  Widget build(BuildContext context) {
    // UserProvider의 인스턴스를 가져와 userProvider 변수에 할당
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      //backgroundColor: background_color,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면의 모든 가장자리에서 16.0의 패딩을 적용
        child: SingleChildScrollView( // 화면을 스크롤 가능하게 하는 위젯
          child: Column( // 위젯들을 세로로 나열하기 위해 Column 사용
            crossAxisAlignment: CrossAxisAlignment.start, // Column 안의 모든 위젯을 왼쪽 정렬
            children: [
              const SizedBox(height: 40), // 상단 여백
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Row 안의 위젯들을 양 끝으로 정렬
                children: [
                  Text(
                    '마이 페이지', // '마이 페이지' 텍스트
                    style: TextStyle(
                      fontSize: 24, // 텍스트 크기 설정
                      fontWeight: FontWeight.bold, // 텍스트 두께 설정
                      color: Colors.black, // 텍스트 색상 설정
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25), // 상단 여백
              Row(
                children: [
                  CircleAvatar(
                    radius: 45, // 아바타의 반지름 설정
                    backgroundImage: userProvider.profileImage != null // 사용자의 프로필 이미지 설정
                        ? NetworkImage(userProvider.profileImage!) as ImageProvider // 프로필 이미지가 있다면 네트워크 이미지 사용
                        : const AssetImage('assets/images/default_profile.png'), // 없다면 기본 이미지 사용
                  ),
                  const SizedBox(width: 25), // 아바타와 텍스트 사이 여백
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트들을 왼쪽 정렬
                    children: [
                      Text(
                        userProvider.nickname, // 사용자 닉네임 출력
                        style: const TextStyle(
                          fontSize: 22, // 텍스트 크기 설정
                          fontWeight: FontWeight.bold, // 텍스트 두께 설정
                          color: Colors.black, // 텍스트 색상 설정
                        ),
                      ),
                      Text(
                        userProvider.email, // 사용자 이메일 출력
                        style: const TextStyle(
                          fontSize: 16, // 텍스트 크기 설정
                          color: Colors.grey, // 텍스트 색상 설정
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30), // 아바타와 거래 정보 사이 여백
              Center(
                child: Column(
                  children: [
                    Text(
                      '나의 거래', // '나의 거래' 텍스트
                      style: TextStyle(
                        fontSize: 20, // 텍스트 크기 설정
                        fontWeight: FontWeight.bold, // 텍스트 두께 설정
                        color: Colors.black, // 텍스트 색상 설정
                      ),
                    ),
                    const SizedBox(height: 10), // 거래 제목과 버튼 사이 여백
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼들을 균등하게 배치
                      children: [
                        _buildTradeButton(
                          context,
                          '판매내역', // 버튼 텍스트
                          Icons.history, // 아이콘
                          _showSalesHistory, // 판매 내역 함수 연결
                        ),
                        _buildTradeButton(
                          context,
                          '구매내역', // 버튼 텍스트
                          Icons.shopping_cart, // 아이콘
                          _showPurchaseHistory, // 구매 내역 함수 연결
                        ),
                        _buildTradeButton(
                          context,
                          '진행중인 경매', // 버튼 텍스트
                          Icons.gavel, // 아이콘
                          _ongoingauction, // 진행 중인 경매 함수 연결
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // 거래 정보와 카드 사이 여백
              Card( // 정보들을 보여줄 카드 위젯
                elevation: 2, // 카드의 그림자 높이 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // 카드의 모서리를 둥글게 설정
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 카드 안쪽에 16.0의 패딩 적용
                  child: Column(
                    children: [
                      ListTile( // 카드 내에서 개별 항목을 나타내는 ListTile 위젯
                        leading: Icon(Icons.person, color: Colors.black), // 왼쪽에 아이콘 설정
                        title: Text('내 정보', style: TextStyle(color: Colors.black)), // 항목 이름 설정
                        onTap: () => _showMyStatus(context), // 탭할 때 내 정보 수정 페이지로 이동
                      ),
                      Divider(), // 항목들 사이에 구분선을 표시
                      ListTile(
                        leading: Icon(Icons.help_outline, color: Colors.black), // 왼쪽에 아이콘 설정
                        title: Text('FAQ', style: TextStyle(color: Colors.black)), // 항목 이름 설정
                        onTap: () => _showFAQ(context), // 탭할 때 FAQ 페이지로 이동
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.policy, color: Colors.black), // 왼쪽에 아이콘 설정
                        title: Text('약관 및 정책', style: TextStyle(color: Colors.black)), // 항목 이름 설정
                        onTap: () => _showTermsAndPolicies(context), // 탭할 때 약관 및 정책 페이지로 이동
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.black), // 왼쪽에 아이콘 설정
                        title: Text('로그아웃', style: TextStyle(color: Colors.black)), // 항목 이름 설정
                        onTap: () => _logout(context), // 탭할 때 로그아웃 기능 실행
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

  // 거래 버튼을 생성하는 함수
  Widget _buildTradeButton(BuildContext context, String text, IconData icon, Function(BuildContext) onTap) {
    return GestureDetector( // 버튼을 감지하는 GestureDetector 위젯
      onTap: () => onTap(context), // 버튼을 탭할 때 onTap 함수 실행
      child: Column(
        children: [
          Container( // 아이콘을 담는 컨테이너
            decoration: BoxDecoration(
              color: button_color, // 버튼의 배경색 설정
              borderRadius: BorderRadius.circular(12), // 버튼 모서리를 둥글게 설정
            ),
            width: 80, // 버튼의 너비 설정
            height: 80, // 버튼의 높이 설정
            child: Icon(icon, size: 40, color: Colors.black), // 아이콘 설정
          ),
          const SizedBox(height: 8), // 아이콘과 텍스트 사이 여백
          Text(text, style: TextStyle(color: Colors.black)), // 버튼 텍스트 설정
        ],
      ),
    );
  }
}
