import 'dart:convert'; // JSON 인코딩 및 디코딩을 위한 라이브러리
import 'package:flutter/material.dart'; // Flutter UI 프레임워크
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import '../providers/item_provider.dart'; // ItemProvider 클래스를 가져오기 위해 import
import '../providers/user_provider.dart'; // UserProvider 클래스를 가져오기 위해 import
import 'item_detail_screen.dart'; // ItemDetailScreen 클래스를 가져오기 위해 import

// 구매 내역 페이지 클래스
class PurchaseHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ItemProvider 인스턴스를 가져옴
    // ItemProvider는 전체 아이템 목록을 관리합니다.
    final itemProvider = Provider.of<ItemProvider>(context);

    // UserProvider 인스턴스를 가져옴
    // UserProvider는 현재 로그인한 사용자 정보를 관리합니다.
    final userProvider = Provider.of<UserProvider>(context);

    // 로그인한 사용자의 ID를 userProvider에서 가져옵니다.
    final userId = userProvider.id;

    // 현재 로그인한 사용자가 낙찰 받은 아이템만 필터링
    // itemProvider의 모든 아이템 중 winnerId가 현재 사용자 ID와 일치하는 아이템만 리스트로 추출합니다.
    final purchasedItems = itemProvider.items.where((item) => item.winnerId == userId).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('구매내역'), // 앱바 제목 설정
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: purchasedItems.length, // 리스트의 아이템 개수 설정
        // 리스트의 각 아이템을 구성하는 빌더 함수
        itemBuilder: (context, index) {
          final item = purchasedItems[index]; // 현재 인덱스의 아이템 가져오기

          // 리스트 항목으로 ListTile 사용
          return ListTile(
            leading: CircleAvatar(
              // 아이템 이미지 설정, 이미지가 없으면 기본 프로필 이미지 사용
              // 아이템 이미지가 있을 경우 첫 번째 이미지를 사용하고, 없으면 기본 이미지를 사용합니다.
              backgroundImage: item.itemImages.isNotEmpty
                  ? NetworkImage(item.itemImages[0]) // 아이템 이미지가 있을 경우
                  : AssetImage('assets/images/default_profile.png') as ImageProvider, // 기본 이미지 사용
              radius: 15,
            ),
            title: Text(item.title),
            subtitle: Text('구매 날짜: ${item.endDateTime.toLocal()}'.split(' ')[0]),
            trailing: Text('₩${item.price}'),
            // 아이템을 탭했을 때 아이템 상세 화면으로 이동
            // Navigator를 사용하여 ItemDetailScreen으로 이동합니다.
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ItemDetailScreen(item: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
