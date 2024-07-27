import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import 'item_detail_screen.dart';

class PurchaseHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.id; // 현재 로그인한 사용자 ID 가져오기

    // 현재 로그인한 사용자가 낙찰 받은 아이템만 필터링
    final purchasedItems = itemProvider.items.where((item) => item.winnerId == userId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('구매내역'),
      ),
      body: ListView.builder(
        itemCount: purchasedItems.length,
        itemBuilder: (context, index) {
          final item = purchasedItems[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: item.itemImages.isNotEmpty
                  ? NetworkImage(item.itemImages[0])
                  : AssetImage('assets/images/default_profile.png') as ImageProvider,
              radius: 15,
            ),
            title: Text(item.title),
            subtitle: Text('구매 날짜: ${item.endDateTime.toLocal()}'.split(' ')[0]),
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
