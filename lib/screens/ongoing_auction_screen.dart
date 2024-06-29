// auction_page.dart
import 'package:flutter/material.dart';
// auction_item.dart
class AuctionItem {
  final String title;
  final String startDate;
  final String endDate; // 종료 날짜 추가
  final double currentBid;
  final String imageUrl; // 이미지 경로 추가

  AuctionItem({
    required this.title,
    required this.startDate,
    required this.endDate, // 종료 날짜 초기화
    required this.currentBid,
    required this.imageUrl, // 이미지 경로 초기화
  });
}

class AuctionPage extends StatelessWidget {
  final List<AuctionItem> auctionItems = [
    AuctionItem(
        title: '경매 상품 1',
        startDate: '2023-01-01',
        endDate: '2023-01-10', // 종료 날짜 추가
        currentBid: 10000.0,
        imageUrl: 'assets/images/charlie.png' // 예시 이미지 경로
    ),
    AuctionItem(
        title: '경매 상품 2',
        startDate: '2023-02-01',
        endDate: '2023-02-10', // 종료 날짜 추가
        currentBid: 20000.0,
        imageUrl: 'assets/images/charlie.png' // 예시 이미지 경로
    ),
    AuctionItem(
        title: '경매 상품 3',
        startDate: '2023-03-01',
        endDate: '2023-03-10', // 종료 날짜 추가
        currentBid: 15000.0,
        imageUrl: 'assets/images/charlie.png' // 예시 이미지 경로
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('진행 중인 경매'),
      ),
      body: ListView.builder(
        itemCount: auctionItems.length,
        itemBuilder: (context, index) {
          final item = auctionItems[index];
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50), // 이미지 추가
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('경매 시작 날짜: ${item.startDate}'),
                Text('경매 종료 날짜: ${item.endDate}'), // 종료 날짜 표시
              ],
            ),
            trailing: Text('현재 입찰가: ₩${item.currentBid.toStringAsFixed(0)}'),
          );
        },
      ),
    );
  }
}
