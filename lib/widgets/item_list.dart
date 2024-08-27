
import 'dart:async'; // 비동기 처리를 위한 패키지
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:cached_network_image/cached_network_image.dart'; // 이미지 캐싱을 위한 패키지
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import '../screens/item_detail_screen.dart';

// 아이템 목록을 보여주는 위젯
class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ScrollController _scrollController = ScrollController(); // 스크롤을 제어하기 위한 ScrollController

  @override
  void didUpdateWidget(covariant ItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent, // 스크롤 위치를 맨 위로 설정
        duration: const Duration(milliseconds: 100), // 애니메이션 지속 시간 설정
        curve: Curves.easeOut, // 애니메이션 커브 설정
      );
    });
  }

  // 금액을 가시적으로 보여주기 위한 함수
  String formatPrice(int price) {
    if (price >= 100000000) {
      int billionPart = (price / 100000000).floor(); // 억 단위로 나누기
      int millionPart = ((price % 100000000) / 10000).floor(); // 만원 단위로 나머지 계산
      return '$billionPart억${millionPart == 0 ? '' : '$millionPart만원'}';
    } else if (price >= 10000) {
      int tenThousandPart = (price / 10000).floor(); // 만 단위로 나누기
      int remainder = price % 10000;
      return remainder == 0 ? '$tenThousandPart만원' : '$tenThousandPart만${remainder.toString().padLeft(4, '0')}원';
    } else {
      return '$price원'; // 만원 미만일 경우 원 단위로 반환
    }
  }

  // 입찰가에 따른 직관적 이해를 돕기 위한 이모티콘 활용한 함수
  String _getEmoji(int difference, bool isAuctionEnded) {
    if (isAuctionEnded) {
      return ''; // 경매 종료 시 이모티콘 표시하지 않음
    } else if (difference > 0) {
      return '🤩'; // 입찰가가 상승했을 때
    } else if (difference == 0) {
      return '☺️'; // 입찰가가 동일할 때
    } else {
      return '🧐'; // 입찰가가 낮아졌을 때
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context); // ItemProvider 인스턴스 가져오기
    final reversedItems = itemProvider.items.reversed.toList(); // 아이템 리스트를 역순으로 정렬

    return ListView.builder(
      controller: _scrollController, // 스크롤 컨트롤러 추가
      itemCount: reversedItems.length, // 아이템 개수 설정
      itemBuilder: (context, index) {
        final item = reversedItems[index]; // 현재 아이템 가져오기

        return FutureBuilder(
          future: Future.wait([
            itemProvider.fetchCurrentPrice(item.id), // 현재 입찰가 가져오기
            itemProvider.fetchRemainingTime(item.id), // 남은 시간 가져오기
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 인디케이터 표시
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // 오류 발생 시 오류 메시지 표시
            } else {
              final currentPrice = snapshot.data![0] as int; // 현재 입찰가
              final initialRemainingTime = snapshot.data![1] as Duration; // 남은 시간

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(item: item), // 아이템 상세 화면으로 이동
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 5.0), // 외부 여백 설정
                      padding: const EdgeInsets.all(6.0), // 내부 여백 설정
                      decoration: const BoxDecoration(
                        color: Colors.white, // 배경색 설정
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // 경계선 색상
                            width: 0.2, // 경계선 두께
                          ),
                        ),
                      ),
                      height: 133.0, // 컨테이너 높이 설정
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 0.09), // 테두리 추가
                              borderRadius: BorderRadius.circular(5.0), // 모서리를 둥글게 설정
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: item.itemImages.isNotEmpty // itemImages가 비어있지 않으면
                                  ? CachedNetworkImage(
                                      imageUrl: item.itemImages[0], // 첫 번째 이미지를 캐싱하여 로드
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(), // 로딩 중일 때 표시할 위젯
                                      errorWidget: (context, url, error) => const Icon(Icons.error), // 로드 실패 시 표시할 위젯
                              )
                                  : const Placeholder(), // 이미지가 없을 경우 Placeholder 사용
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 7),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentPrice == 0
                                          ? "${_getEmoji(currentPrice - item.price, initialRemainingTime.isNegative || initialRemainingTime.inSeconds == 0)}입찰자 없음 "
                                          : '${_getEmoji(currentPrice - item.price, initialRemainingTime.isNegative || initialRemainingTime.inSeconds == 0)}${formatPrice(currentPrice)}', // 현재 입찰가 텍스트
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold, // 입찰가 텍스트 스타일
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      formatPrice(item.price), // 시초가 텍스트
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black, // 시초가 텍스트 스타일
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    RemainingTimeGrid(
                                        initialEndDateTime: item.endDateTime),// 남은 시간 표시 위젯
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

// 경매 종료까지 남은 시간을 표시하는 위젯
class RemainingTimeGrid extends StatefulWidget {
  final DateTime initialEndDateTime; // 경매 종료 시간

  const RemainingTimeGrid({Key? key, required this.initialEndDateTime})
      : super(key: key);

  @override
  _RemainingTimeGridState createState() => _RemainingTimeGridState();
}

class _RemainingTimeGridState extends State<RemainingTimeGrid> {
  late Timer timer; // 매초마다 시간을 업데이트하기 위한 타이머

  @override
  void initState() {
    super.initState();
    // 매초마다 setState를 호출하여 남은 시간을 업데이트
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel(); // 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = widget.initialEndDateTime.difference(DateTime.now()); // 현재 시간과 경매 종료 시간의 차이 계산

    final int days = remainingTime.isNegative ? 0 : remainingTime.inDays; // 남은 일 계산
    final int hours = remainingTime.isNegative ? 0 : remainingTime.inHours.remainder(24); // 남은 시간 계산
    final int minutes = remainingTime.isNegative ? 0 : remainingTime.inMinutes.remainder(60); // 남은 분 계산
    final int seconds = remainingTime.isNegative ? 0 : remainingTime.inSeconds.remainder(60); // 남은 초 계산

    String displayText;
    if (days > 0) {
      displayText = "남은 시간 : $days일";
    } else if (hours > 0) {
      displayText = "남은 시간 : $hours시간";
    } else if (minutes > 0) {
      displayText = "남은 시간 : $minutes분";
    } else {
      displayText = seconds == 0 ? "판매 완료" : "남은 시간 : $seconds초";
    }

    return Container(
      margin: const EdgeInsets.only(top: 0.0), // 그리드와 텍스트 간의 간격 추가
      decoration: BoxDecoration(
        color: seconds == 0 ? Colors.white : Colors.redAccent,
        borderRadius: BorderRadius.circular(9.0), // 모서리를 둥글게 설정
      ),
      child: Align(
        alignment: seconds == 0 ?Alignment.centerLeft:Alignment.center, // 텍스트를 왼쪽으로 정렬
        child: Padding(
          padding: const EdgeInsets.all(3.0), // 텍스트와 컨테이너 간의 간격 추가
          child: Text(
            displayText,
            style: TextStyle(
              color: seconds == 0 ? Colors.black : Colors.white,
              fontSize: 14, // 텍스트 크기 설정
              fontWeight: FontWeight.bold, // 텍스트 굵기 설정
            ),
          ),
        ),
      ),
    );
  }
}
