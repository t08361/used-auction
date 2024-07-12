import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../screens/item_detail_screen.dart';

class ItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    return ListView.builder(
      itemCount: itemProvider.items.length,
      itemBuilder: (context, index) {
        final item = itemProvider.items[index];

        return FutureBuilder(
          future: Future.wait([
            itemProvider.fetchCurrentPrice(item.id),
            itemProvider.fetchRemainingTime(item.id),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final currentPrice = snapshot.data![0] as int;
              final remainingTime = snapshot.data![1] as Duration;

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0), // 아이템 간의 간격 설정
                  padding: const EdgeInsets.all(6.0), // 아이템 내부 여백 설정
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: 135.0, // 아이템의 높이 설정
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: item.itemImage != null
                              ? Image.memory(
                            base64Decode(item.itemImage!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                              : Placeholder(), // 이미지가 없을 경우
                        ),
                      ),
                      const SizedBox(width: 10), // 이미지와 텍스트 간의 간격 설정
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 텍스트 크기 조정
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: TextStyle(fontSize: 14), // 텍스트 크기 조정
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // 한 줄까지만 표시하고 나머지는 ...로 표시
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '시초가 : ${item.price}원',
                              style: const TextStyle(fontSize: 15, color: Colors.green), // 텍스트 크기 및 색상 조정
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '현재 최고가 : ${currentPrice}원',
                              style: TextStyle(fontSize: 15, color: Colors.red), // 텍스트 크기 및 색상 조정
                            ),
                            Text(
                              "남은 시간 : ${remainingTime.inMinutes}분",
                              style: TextStyle(fontSize: 14), // 텍스트 크기 조정
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
