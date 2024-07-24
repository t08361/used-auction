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
//금액을 가시적으로 보여지게 하기위한 함수
  String formatPrice(int price) {
    if (price >= 100000000) {
      int billionPart = (price / 100000000).floor();
      int millionPart = ((price % 100000000) / 10000).floor();
      return '${billionPart}억${millionPart == 0 ? '' : '$millionPart만원'}';
    } else if (price >= 10000) {
      int tenThousandPart = (price / 10000).floor();
      int remainder = price % 10000;
      return remainder == 0 ? '${tenThousandPart}만원' : '${tenThousandPart}만${remainder.toString().padLeft(4, '0')}원';
    } else {
      return '${price}원';
    }
  }
//입찰가에 따른 직관적 이해를 돕기위한 이모티콘 활용한 함수
  String _getEmoji(int difference, bool isAuctionEnded) {
    if (isAuctionEnded) {
      return '';
    } else if (difference > 0) {
      return '🤩';
    } else if (difference == 0) {
      return '☺️';
    } else {
      return '🧐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final reversedItems =
        itemProvider.items.reversed.toList(); // 1. 리스트를 역순으로 정렬

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
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1.2), // 테두리 추가
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  item.title ,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentPrice == 0
                                          ? _getEmoji(currentPrice - item.price, initialRemainingTime.isNegative || initialRemainingTime.inSeconds == 0)+"입찰자 없음 "
                                          : _getEmoji(currentPrice - item.price, initialRemainingTime.isNegative || initialRemainingTime.inSeconds == 0)+'${formatPrice(currentPrice)}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        //color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${formatPrice(item.price)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    RemainingTimeGrid(
                                        initialEndDateTime: item.endDateTime),
                                  ],
                                ),
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
  final DateTime initialEndDateTime;

  const RemainingTimeGrid({Key? key, required this.initialEndDateTime})
      : super(key: key);

  @override
  _RemainingTimeGridState createState() => _RemainingTimeGridState();
}

class _RemainingTimeGridState extends State<RemainingTimeGrid> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = widget.initialEndDateTime.difference(DateTime.now());

    final int days = remainingTime.isNegative ? 0 : remainingTime.inDays;

    final int hours =
        remainingTime.isNegative ? 0 : remainingTime.inHours.remainder(24);
    final int minutes =
        remainingTime.isNegative ? 0 : remainingTime.inMinutes.remainder(60);
    final int seconds =
        remainingTime.isNegative ? 0 : remainingTime.inSeconds.remainder(60);

    String displayText;
    if (days > 0) {
      displayText = "$days일";
    } else if (hours > 0) {
      displayText = "$hours시간";
    } else if (minutes > 0) {
      displayText = "$minutes분";
    } else {
      displayText = seconds == 0 ? "경매 종료" : "$seconds초";
    }

    return Container(
      margin: const EdgeInsets.only(top: 0.0), // 그리드와 텍스트 간의 간격 추가
      decoration: BoxDecoration(
        color: seconds == 0 ? Colors.black : Colors.redAccent,
        borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게 설정
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0), // 텍스트와 컨테이너 간의 간격 추가
          child: Text(
            displayText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // 텍스트 크기 설정
              fontWeight: FontWeight.bold, // 텍스트 굵기 설정
            ),
          ),
        ),
      ),
    );
  }
}
