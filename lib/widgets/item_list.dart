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
            height: 120.0, // 아이템의 높이 설정
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      item.imageFile,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
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
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '시초가 : ${item.price}원',
                        style: const TextStyle(fontSize: 15, color: Colors.green), // 텍스트 크기 및 색상 조정
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '현재 최고가 : 32220원',
                        style: TextStyle(fontSize: 15, color: Colors.red), // 텍스트 크기 및 색상 조정
                      ),
                      const Text(
                        "남은 시간 : 32분",
                        style: TextStyle(fontSize: 14), // 텍스트 크기 조정
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}