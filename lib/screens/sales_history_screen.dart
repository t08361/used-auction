import 'package:flutter/material.dart';
// sale_item.dart
class SaleItem {
  final String title;
  final String date;
  final double price;
  final String imageUrl;

  SaleItem({
    required this.title,
    required this.date,
    required this.price,
  required this.imageUrl,
  });
}
// sale_history_page.dart
class SaleHistoryPage extends StatelessWidget {
  final List<SaleItem> saleHistory = [
    SaleItem(
        title: '상품 1',
        date: '2023-01-01',
        price: 10000.0,
        imageUrl: 'assets/images/charlie.png' // 예시 이미지 경로
    ),
    SaleItem(
        title: '상품 2',
        date: '2023-02-01',
        price: 20000.0,
        imageUrl: 'assets/images/tent.png'  // 예시 이미지 경로
    ),
    SaleItem(
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
        title: Text('판매내역'),
      ),
      body: ListView.builder(
        itemCount: saleHistory.length,
        itemBuilder: (context, index) {
          final item = saleHistory[index];
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50), // 이미지 추가
            title: Text(item.title),
            subtitle: Text('판매 날짜: ${item.date}'),
            trailing: Text('₩${item.price.toStringAsFixed(0)}'),
          );
        },
      ),
    );
  }
}