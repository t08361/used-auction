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

              // 남은 시간을 일, 시간, 분, 초로 변환
              final int days = remainingTime.inDays;
              final int hours = remainingTime.inHours.remainder(24);
              final int minutes = remainingTime.inMinutes.remainder(60);
              final int seconds = remainingTime.inSeconds.remainder(60);

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
                      const SizedBox(width: 20), // 이미지와 텍스트 간의 간격 설정
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5, // 글자 영역의 너비를 제한
                        height: 100.0, // 글자 영역의 높이 제한
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal), // 텍스트 크기 조정
                              ),
                              const SizedBox(height: 1),
                              Text(
                                item.description,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal,color: Colors.grey), // 텍스트 크기 조정
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // 한 줄까지만 표시하고 나머지는 ...로 표시
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    '${item.price}원 ~',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF729762)), // 텍스트 크기 및 색상 조정
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${currentPrice}원',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF729762)), // 텍스트 크기 및 색상 조정
                                  ),
                                ],
                              ),

                              Text(
                                "${days}일 ${hours}시간 ${minutes}분 ${seconds}초",
                                style: TextStyle(fontSize: 14), // 텍스트 크기 조정
                              ),
                            ],
                          ),
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