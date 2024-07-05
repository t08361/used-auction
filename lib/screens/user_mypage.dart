import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // Provider 패키지 import
import '../main.dart';
import '../providers/user_provider.dart'; // UserProvider import
import 'ongoing_auction_screen.dart'; // 진행중인 경매 화면 import
import 'edit_profile_screen.dart'; // 프로필 수정 화면 import
import 'sales_history_screen.dart'; // 판매 내역 화면 import
import 'purchase_history_screen.dart'; // 구매 내역 화면 import
import 'FAQ_screen.dart'; // FAQ 화면 import
import 'terms_and_policies_screen.dart'; // 약관 및 정책 화면 import
import 'login_screen.dart'; // 로그인 화면 import

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

  // 간편 회원가입 처리 로직 (미구현)
  void _signup(BuildContext context) {
    // 서버에 요청을 보내고 응답을 처리하는 로직 추가 예정
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
    Navigator.of(context).pushReplacementNamed('/login'); // 로그인 화면으로 이동
  }

  // 사용자 페이지의 UI 빌드
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'), // 앱바 타이틀 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 설정
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 공간을 고르게 분배
          children: [
            // 프로필 사진과 닉네임을 표시하는 Row 위젯
            Row(
              children: [
                CircleAvatar(
                  radius: 40, // 원형 아바타의 반지름 설정
                  backgroundImage: AssetImage('assets/images/charlie.png'), // 프로필 사진 경로 설정
                ),
                SizedBox(width: 16), // 간격 설정
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 시작점 기준 정렬
                  children: [
                    Text(
                      userProvider.nickname, // 닉네임 텍스트
                      style: TextStyle(
                        fontSize: 20, // 폰트 크기 설정
                        fontWeight: FontWeight.bold, // 폰트 두께 설정
                        color: Colors.black
                      ),
                    ),
                    Text(
                      userProvider.email, // 이메일 텍스트
                      style: TextStyle(
                        fontSize: 16, // 폰트 크기 설정
                        color: Colors.grey, // 폰트 색상 설정

                      ),
                    ),
                  ],
                ),
              ],
            ),
            // 각 버튼에 onPressed 이벤트 연결
            ElevatedButton(
              onPressed: () => _showMyStatus(context), // 내 정보 버튼 클릭 시 이벤트
              child: Text('내 정보'),
            ),
            ElevatedButton(
              onPressed: () => _showSalesHistory(context), // 판매내역 버튼 클릭 시 이벤트
              child: Text('판매내역'),
            ),
            ElevatedButton(
              onPressed: () => _showPurchaseHistory(context), // 구매내역 버튼 클릭 시 이벤트
              child: Text('구매내역'),
            ),
            ElevatedButton(
              onPressed: () => _ongoingauction(context), // 진행중인 경매 버튼 클릭 시 이벤트
              child: Text('진행중인 경매'),
            ),
            ElevatedButton(
              onPressed: () => _showFAQ(context), // FAQ 버튼 클릭 시 이벤트
              child: Text('FAQ'),
            ),
            ElevatedButton(
              onPressed: () => _showTermsAndPolicies(context), // 약관 및 정책 버튼 클릭 시 이벤트
              child: Text('약관 및 정책'),
            ),
            ElevatedButton(
              onPressed: () => _logout(context), // 로그아웃 버튼 클릭 시 이벤트
              child: Text('로그아웃'),
              style: ElevatedButton.styleFrom(primary: Colors.red), // 버튼 색상 설정
            ),
          ],
        ),
      ),
    );
  }
}