import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart'; // 추가
import 'item_detail_screen.dart';

class SaleHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final userProvider = Provider.of<UserProvider>(context); // 추가
    final userId = userProvider.id; // 현재 로그인한 사용자 ID 가져오기

    // 현재 로그인한 사용자가 등록한 아이템만 필터링
    final userItems = itemProvider.items.where((item) => item.userId == userId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('판매내역'),
      ),
      body: ListView.builder(
        itemCount: userItems.length,
        itemBuilder: (context, index) {
          final item = userItems[index];
          return ListTile(
            leading: item.itemImage != null
                ? Image.memory(base64Decode(item.itemImage!), width: 50, height: 50)
                : Placeholder(fallbackWidth: 50, fallbackHeight: 50),
            title: Text(item.title),
            subtitle: Text('판매 날짜: ${item.endDateTime.toLocal()}'.split(' ')[0]),
            trailing: Text('₩${item.price}'),
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
