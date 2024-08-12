// auction_page.dart
import 'package:flutter/material.dart';
// auction_item.dart
// 경매 아이템을 나타내는 모델
class AuctionItem {
  final String title; // 경매 아이템의 제목
  final String startDate; // 경매 시작 날짜
  final String endDate; // 경매 종료 날짜
  final double currentBid; // 현재 입찰가
  final String imageUrl; // 경매 아이템의 이미지 경로


  AuctionItem({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.currentBid,
    required this.imageUrl,
  });
}

// 경매 페이지
class AuctionPage extends StatelessWidget {
  // 예시로 사용할 경매 아이템 목록
  final List<AuctionItem> auctionItems = [
    AuctionItem(
        title: '경매 상품 1',
        startDate: '2023-01-01',
        endDate: '2023-01-10',
        currentBid: 10000.0,
        imageUrl: 'assets/images/charlie.png'
    ),
    AuctionItem(
        title: '경매 상품 2',
        startDate: '2023-02-01',
        endDate: '2023-02-10',
        currentBid: 20000.0,
        imageUrl: 'assets/images/tent.png'
    ),
    AuctionItem(
        title: '경매 상품 3',
        startDate: '2023-03-01',
        endDate: '2023-03-10',
        currentBid: 15000.0,
        imageUrl: 'assets/images/tools.png'
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('진행 중인 경매'), // 앱바 제목
      ),
      // 경매 아이템 목록을 보여주는 ListView
      body: ListView.builder(
        itemCount: auctionItems.length, // 목록의 아이템 수
        itemBuilder: (context, index) {
          final item = auctionItems[index]; // 현재 인덱스의 아이템 가져오기
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50), // 아이템 이미지 표시
            title: Text(item.title), // 아이템 제목 표시
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('경매 시작 날짜: ${item.startDate}'),
                Text('경매 종료 날짜: ${item.endDate}'),
              ],
            ),
            trailing: Text('현재 입찰가: ₩${item.currentBid.toStringAsFixed(0)}'),
          );
        },
      ),
    );
  }
}
