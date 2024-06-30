import 'package:flutter/material.dart';
class PurchaseItem {
  final String title;
  final String date;
  final double price;
  final String imageUrl; // 이미지 경로 추가

  PurchaseItem({
    required this.title,
    required this.date,
    required this.price,
    required this.imageUrl, // 이미지 경로 초기화
  });
}
// purchase_history_page.dart
class PurchaseHistoryPage extends StatelessWidget {
  final List<PurchaseItem> purchaseHistory = [
    PurchaseItem(
        title: '상품 1',
        date: '2023-01-01',
        price: 10000.0,
        imageUrl: 'assets/images/charlie.png'  // 예시 이미지 경로
    ),
    PurchaseItem(
        title: '상품 2',
        date: '2023-02-01',
        price: 20000.0,
        imageUrl: 'assets/images/tent.png'  // 예시 이미지 경로
    ),
    PurchaseItem(
        title: '상품 3',
        date: '2023-03-01',
        price: 15000.0,
        imageUrl: 'assets/images/tools.png'  // 예시 이미지 경로
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구매내역'),
      ),
      body: ListView.builder(
        itemCount: purchaseHistory.length,
        itemBuilder: (context, index) {
          final item = purchaseHistory[index];
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50), // 이미지 추가
            title: Text(item.title),
            subtitle: Text('구매 날짜: ${item.date}'),
            trailing: Text('₩${item.price.toStringAsFixed(0)}'),
          );
        },
      ),
    );
  }
}
