import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/constants.dart';
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
              final initialRemainingTime = snapshot.data![1] as Duration;

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey, // 경계선 색상
                        width: 0.2, // 경계선 두께
                      ),
                    ),
                  ),
                  height: 125.0,
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
                              : Placeholder(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                Text(
                                  '${item.price}원 ~',
                                  style: TextStyle(fontSize: 12, color:Colors.black),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${currentPrice}원',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                            StreamBuilder<int>(
                              stream: Stream.periodic(Duration(seconds: 1), (i) => i),
                              builder: (context, timerSnapshot) {
                                final remainingTime = initialRemainingTime - Duration(seconds: timerSnapshot.data ?? 0);

                                final int days = remainingTime.inDays;
                                final int hours = remainingTime.inHours.remainder(24);
                                final int minutes = remainingTime.inMinutes.remainder(60);
                                final int seconds = remainingTime.inSeconds.remainder(60);

                                return Text(
                                  "${days}일 ${hours}시간 ${minutes}분 ${seconds}초",
                                  style: TextStyle(fontSize: 14),
                                );
                              },
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
