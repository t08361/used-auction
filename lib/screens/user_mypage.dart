import 'package:flutter/material.dart';
import 'package:testhandproduct/screens/ongoing_auction_screen.dart';
import 'edit_profile_screen.dart'; // EditProfilePage import 추가
import 'sales_history_screen.dart';
import 'purchase_history_screen.dart';
import 'FAQ_screen.dart';
import 'terms_and_policies_screen.dart';
class UserPage extends StatelessWidget {
  static const routeName = '/social-signup';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _showMyStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()), // 내 정보 수정 페이지로 이동
    );
  }

  void _signup(BuildContext context) {
    // 간편 회원가입 처리 로직
    // 예를 들어, 서버에 요청을 보내고 응답을 처리합니다.
  }
  void _ongoingauction(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>AuctionPage()),
    );
  }
  void _showSalesHistory(BuildContext context) {
    // 판매내역 버튼 클릭 시 처리 로직
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>SaleHistoryPage()),
    );
  }

  void _showPurchaseHistory(BuildContext context) {
    // 구매내역 버튼 클릭 시 처리 로직
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>PurchaseHistoryPage()),
    );
  }

  void _showFAQ(BuildContext context) {
    // FAQ 버튼 클릭 시 처리 로직
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>FAQPage()),
    );
  }

  void _showTermsAndPolicies(BuildContext context) {
    // 약관 및 정책 버튼 클릭 시 처리 로직
    Navigator.push(
      context,
      MaterialPageRoute(builder:(context)=>TermsAndPoliciesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 프로필 사진과 닉네임
            const Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.jpg'), // 프로필 사진 경로 설정
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '닉네임',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'user@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showMyStatus(context),
              child: Text('내 정보'),
            ),
            ElevatedButton(
              onPressed: () => _showSalesHistory(context),
              child: Text('판매내역'),
            ),
            ElevatedButton(
              onPressed: () => _showPurchaseHistory(context),
              child: Text('구매내역'),
            ),
            ElevatedButton(
              onPressed: () => _ongoingauction(context),
              child: Text('진행중인 경매'),
            ),
            ElevatedButton(
              onPressed: () => _showFAQ(context),
              child: Text('FAQ'),
            ),
            ElevatedButton(
              onPressed: () => _showTermsAndPolicies(context),
              child: Text('약관 및 정책'),
            ),
          ],
        ),
      ),
    );
  }
}
