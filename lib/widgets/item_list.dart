import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/constants.dart';
import '../providers/item_provider.dart';
import '../screens/item_detail_screen.dart';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
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

              return Column(
                children: [
                  GestureDetector(
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
                            width: 120,
                            height: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: item.itemImage != null
                                  ? Image.memory(
                                base64Decode(item.itemImage!),
                                width: 120,
                                height: 120,
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
                                      '최고가 : ${currentPrice}원 ~',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.price}원',
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                                RemainingTimeGrid(initialRemainingTime: initialRemainingTime),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 그리드 추가
                ],
              );
            }
          },
        );
      },
    );
  }
}

class RemainingTimeGrid extends StatefulWidget {
  final Duration initialRemainingTime;

  const RemainingTimeGrid({Key? key, required this.initialRemainingTime}) : super(key: key);

  @override
  _RemainingTimeGridState createState() => _RemainingTimeGridState();
}

class _RemainingTimeGridState extends State<RemainingTimeGrid> {
  late Duration remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialRemainingTime;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime -= Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int days = remainingTime.inDays;
    final int hours = remainingTime.inHours.remainder(24);
    final int minutes = remainingTime.inMinutes.remainder(60);
    final int seconds = remainingTime.inSeconds.remainder(60);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4, // 그리드 아이템 수
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 한 줄에 두 개의 아이템
        childAspectRatio: 2, // 아이템 비율
      ),
      itemBuilder: (context, gridIndex) {
        String text;
        switch (gridIndex) {
          case 0:
            text = "${days}일";
            break;
          case 1:
            text = "${hours}시간";
            break;
          case 2:
            text = "${minutes}분";
            break;
          case 3:
            text = "${seconds}초";
            break;
          default:
            text = "";
        }
        return Container(
          margin: const EdgeInsets.all(4.0),
          color: Colors.blueAccent,
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}