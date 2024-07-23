import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../screens/item_detail_screen.dart';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final reversedItems = itemProvider.items.reversed.toList(); // 1. 리스트를 역순으로 정렬

    return ListView.builder(
      controller: _scrollController, // 스크롤 컨트롤러 추가
      itemCount: reversedItems.length,
      itemBuilder: (context, index) {
        final item = reversedItems[index];

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
                      margin: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 5.0),
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
                              child: item.itemImage.isNotEmpty // itemImage가 비어있지 않으면
                                  ? Image.network(item.itemImage, fit: BoxFit.cover)
                                  : Placeholder(), // 비어있으면 Placeholder 사용
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
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(height: 13),
                                Row(
                                  children: [
                                    Text(
                                      '최고가 : ${currentPrice}원 ~',
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.price}원',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                                RemainingTimeGrid(
                                    initialRemainingTime: initialRemainingTime),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        remainingTime = remainingTime - Duration(seconds: 1);
        if (remainingTime.isNegative) {
          remainingTime = Duration.zero;
        }
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
    final int days = remainingTime.isNegative ? 0 : remainingTime.inDays;
    final int hours = remainingTime.isNegative ? 0 : remainingTime.inHours.remainder(24);
    final int minutes = remainingTime.isNegative ? 0 : remainingTime.inMinutes.remainder(60);
    final int seconds = remainingTime.isNegative ? 0 : remainingTime.inSeconds.remainder(60);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4, // 그리드 아이템 수
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 한 줄에 네 개의 아이템
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
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게 설정
          ),
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
