import 'dart:convert'; // JSON 변환을 위한 다트 라이브러리
import 'package:flutter/material.dart'; // 플러터의 UI 라이브러리
import 'package:provider/provider.dart'; // 상태 관리 라이브러리
import '../providers/item_provider.dart'; // 아이템 관련 프로바이더를 불러옴
import '../providers/user_provider.dart'; // 사용자 관련 프로바이더를 불러옴
import 'item_detail_screen.dart'; // 아이템 상세 화면을 불러옴

// 판매 내역 페이지 클래스
class SaleHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ItemProvider와 UserProvider 인스턴스
    final itemProvider = Provider.of<ItemProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // 현재 로그인한 사용자의 ID를 userProvider에서 가져옴
    final userId = userProvider.id;

    // 현재 로그인한 사용자가 등록한 아이템만 필터링
    // itemprovider의 아이템중 item.userId와 현재사용자의 Id가 일치하는 상품만 추출
    final userItems = itemProvider.items.where((item) => item.userId == userId).toList();

    return Scaffold(

      appBar: AppBar(
        title: Text('판매내역'),
      ),

      body: ListView.builder(
        itemCount: userItems.length, // 아이템 개수 설정
        itemBuilder: (context, index) {// 아이템을 어떻게 표시할지 정의
          final item = userItems[index]; // 현재 인덱스의 아이템을 가져옴
          return ListTile(
            // 아이템의 이미지를 원형 아바타로 표시
            leading: CircleAvatar(
              backgroundImage: item.itemImages.isNotEmpty
                  ? NetworkImage(item.itemImages[0]) // 아이템 이미지가 있으면 첫 번째 이미지 사용
                  : AssetImage('assets/images/default_profile.png') as ImageProvider, // 이미지가 없으면 기본 이미지 사용
              radius: 15,
            ),

            title: Text(item.title),
            subtitle: Text('판매 날짜: ${item.endDateTime.toLocal()}'.split(' ')[0]),
            trailing: Text('₩${item.price}'),
            onTap: () {
              // 아이템을 탭했을 때 아이템 상세 화면으로 이동
              // Navigator를 사용하여 ItemDetailScreen으로 이동합니다.
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
