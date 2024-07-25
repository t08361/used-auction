import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:testhandproduct/models/chatRoom.dart';
import '../models/item.dart';
import '../providers/chat_provider.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import '../providers/constants.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;

import 'ItemEditScreen.dart';
import 'chat_screen.dart';
import 'purchase_history_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int currentPrice = -1; // 현재 최고가를 담을 변수
  late Duration remainingTime; // 종료까지 남은 시간 계산
  List<Map<String, dynamic>> bids = []; // 현재 입찰 기록을 담을 리스트
  String sellerNickname = ''; // 판매자의 닉네임
  bool _showChatButton = false; // 대화하기 버튼을 표시할지 여부를 담는 변수
  Timer? _timer; // 남은 시간을 지속적으로 업데이트하기 위한 타이머
  String winnerId = ''; // 가장 높은 입찰가를 제시한 사용자의 ID를 저장할 변수
  String winnerNickname = ''; // 낙찰자의 닉네임
  String itemImage = '';

  @override
  void initState() {
    super.initState();
    remainingTime = widget.item.endDateTime.difference(DateTime.now());
    fetchBids(); // 입찰 기록 가져오기 호출
    fetchSellerNickname(); // 판매자의 닉네임 가져오기
    currentPrice = widget.item.lastPrice;
    _startTimer(); // 타이머 시작

    // 남은 시간이 0 이하일 경우 초기 상태 설정
    if (remainingTime.isNegative || remainingTime.inSeconds == 0) {
      remainingTime = Duration.zero;
      _setWinningBid();
      _showChatButton = true;
    } else {
      _startTimer(); // 타이머 시작
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  // 판매자의 닉네임과 지역 정보 가져오기
  Future<void> fetchSellerNickname() async {
    final url = Uri.parse('$baseUrl/users/${widget.item.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> user = json.decode(response.body);
      setState(() {
        sellerNickname = user['nickname'];
      });
      print('판매자 닉네임 : $sellerNickname');
    } else {
      print('판매자 닉네임 가져오기 실패');
    }
  }

  // 현재 상품의 입찰 기록을 가져오기
  Future<void> fetchBids() async {
    final url = Uri.parse('$baseUrl/bids/${widget.item.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> bidList = json.decode(response.body);
      setState(() {
        bids = bidList.map((bid) =>
        {
          'nickname': bid['nickname'], // 입찰자의 닉네임
          'bidPrice': bid['bid']['bidAmount'], // 입찰 금액
          'bidderId': bid['bid']['bidderId'], // 입찰자 ID 추가
        }).toList();
      });
    } else {
      print('입찰 기록을 가져오기 실패');
    }
  }

  // 입찰 기록에 데이터 넣기
  Future<void> _placeBid(int bidAmount) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final url = Uri.parse('$baseUrl/bids');

    final bidData = {
      'itemId': widget.item.id,
      'bidderId': userProvider.id,
      'bidAmount': bidAmount,
      'bidTime': DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bidData),
    );

    if (response.statusCode == 201) {
      setState(() {
        currentPrice = bidAmount; // 입찰 성공 후 currentPrice 업데이트
      });
      fetchBids(); // 입찰 성공 후 입찰 기록 다시 가져오기
      print('입찰 성공!');
      print('bidData: $bidData');
    } else {
      print('입찰 실패: ${response.body}');
    }
  }

  // 입찰 버튼을 눌렀을 때 호출되는 함수
  void _showBidDialog() {
    int _currentBidStep = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('입찰하기'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('현재가: \$${currentPrice}'),
                  const SizedBox(height: 10),
                  Text('입찰 단위: \$${widget.item.bidUnit}'),
                  const SizedBox(height: 10),
                  NumberPicker(
                    minValue: 1,
                    maxValue: 100,
                    value: _currentBidStep,
                    onChanged: (value) {
                      setState(() {
                        _currentBidStep = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('입찰 금액: \$${currentPrice +
                      widget.item.bidUnit * _currentBidStep}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final enteredBid = currentPrice +
                        widget.item.bidUnit * _currentBidStep;
                    setState(() {
                      currentPrice = enteredBid;
                    });
                    await _placeBid(enteredBid); // 백엔드로 입찰 정보 전송
                    Navigator.of(ctx).pop();
                  },
                  child: Text('입찰'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 중복된 _setWinningBid 함수 제거 및 함수 이름 변경
  void _setWinningBid() {
    if (bids.isNotEmpty) {
      final highestBid = bids.reduce((curr, next) =>
      curr['bidPrice'] > next['bidPrice'] ? curr : next);
      final highestBidAmount = highestBid['bidPrice'];
      final highestBidderId = highestBid['bidderId'] ?? ''; // Null일 경우 빈 문자열로 처리
      final highestBidderNickname = highestBid['nickname'] ?? ''; // 낙찰자의 닉네임

      setState(() {
        currentPrice = highestBidAmount;
        winnerId = highestBidderId; // 가장 높은 입찰가를 제시한 사용자의 ID 저장
        winnerNickname = highestBidderNickname; // 낙찰자의 닉네임 저장
        _showChatButton = true; // 낙찰자가 정해지면 대화 버튼을 표시하도록 설정
      });
      // 디버그 로그 추가
      print("Highest bid amount: $highestBidAmount");
      print("Highest bidder ID: $highestBidderId");

      // 낙찰자를 서버에 업데이트
      _updateWinner(currentPrice, winnerId);
    }
  }

  Future<void> _updateWinner(int lastPrice, String winnerId) async {
    final url = Uri.parse('$baseUrl/items/${widget.item.id}/winningBid');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'lastPrice': lastPrice, 'winnerId': winnerId}),
    );

    if (response.statusCode == 200) {
      print('낙찰가 업데이트 성공');
      // 낙찰가 업데이트 성공 시 PurchaseHistoryPage로 이동
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => PurchaseHistoryPage(),
      //   ),
      // );
    } else {
      print('낙찰가 업데이트 실패: ${response.body}');
    }
  }

  // 1. 타이머 시작 (_startTimer 메서드): 경매 종료 시간을 계산하고 타이머를 시작합니다.
  // 2. 타이머 만료 처리: 타이머가 만료되면 (remainingTime이 0 또는 음수가 되면) _setWinningBid 메서드를 호출합니다.
  // 3. 최고 입찰자 선정 (_setWinningBid 메서드): bids 리스트에서 가장 높은 입찰가를 찾고, 해당 입찰자를 낙찰자로 선정합니다. 이후 _updateWinner 메서드를 호출하여 서버에 낙찰 정보를 업데이트합니다.
  // 4. 낙찰 정보 서버 업데이트 (_updateWinner 메서드): 최고 입찰가와 낙찰자의 ID를 서버에 업데이트합니다.
  void _startTimer() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = widget.item.endDateTime.difference(DateTime.now());
        if (remainingTime.isNegative || remainingTime.inSeconds == 0) {
          _showChatButton = true;
          _setWinningBid(); // 남은 시간이 0이 되면 낙찰가 설정
          remainingTime = Duration.zero; // 남은 시간을 0으로 설정
          timer.cancel(); // 타이머 취소
          final chatRoomId = getChatRoomId(userProvider.id, widget.item.userId);
          final lastMessage = chatProvider.getLastMessageForChatRoom(chatRoomId);
          chatProvider.createChatRoom(
            userProvider.id,
            userProvider.nickname,
            widget.item.userId,
            sellerNickname,
            lastMessage ?? '',
            widget.item.itemImage ?? '',
          );
        }
      });
    });
  }

  void _handleMenuSelection(String value) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    //final userProvider = Provider.of<UserProvider>(context, listen: false);
    switch (value) {
      case 'edit': //수정
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ItemEditScreen(item: widget.item),
          ),
        );
        break;
      case 'delete': //삭제
        try {
          await itemProvider.deleteItem(widget.item.id);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 완료')),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $error')),
          );
        }
        break;
      case 'report':
      // 신고하기 기능 추가
        break;
    }
  }

  String getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final bool isOwner = widget.item.userId == userProvider.id;
    final bool isLoggedInUserWinner = userProvider.id == winnerId;
    final bool isLoggedInUserSeller = userProvider.id == widget.item.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상품명 : ' + widget.item.title,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상을 검은색으로 설정
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 이미지 추가 부분 ( starttimer의 영향을 안받게 하기 위해 future로 묶어 builder와 완전히 분리하였다. )
              widget.item.itemImage.isNotEmpty
                  ? SizedBox(
                width: double.infinity,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.item.itemImage,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : SizedBox.shrink(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '닉네임 : ' + sellerNickname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '지역 : ' + widget.item.region,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuSelection,
                    itemBuilder: (BuildContext context) {
                      if (isOwner && userProvider.isLoggedIn) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('수정하기'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('삭제하기'),
                          ),
                        ];
                      } else {
                        return [
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Text('신고하기'),
                          ),
                        ];
                      }
                    },
                    child: const Icon(Icons.more_vert), // 아이콘으로 대체
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '자세한 설명 : ' + widget.item.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '시초가: \$${widget.item.price}',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 10),
              Text(
                '현재가: \$${currentPrice}',
                style: const TextStyle(fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 10),
              Text(
                '종료까지 남은 시간: ${remainingTime.inDays}일 ${remainingTime.inHours % 24}시간 ${remainingTime.inMinutes % 60}분 ${remainingTime.inSeconds % 60}초',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                '입찰 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              bids.isEmpty
                  ? const Text('아직 입찰 기록이 없습니다!',
                  style: TextStyle(fontSize: 16, color: Colors.grey))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bids.length,
                itemBuilder: (ctx, index) {
                  final bid = bids[index];
                  return ListTile(
                    title: Text(bid['nickname'] as String),
                    subtitle: Text('입찰가: \$${bid['bidPrice']}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (isLoggedInUserSeller)
                Center(
                  child: Text(
                    '내가 등록한 상품',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              if (!isOwner && !isLoggedInUserWinner &&
                  !userProvider.isLoggedIn && !_showChatButton)
                Column(
                  children: [
                    Center(
                      child: Text(
                        "경매가 완료 되었습니다",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              if (!isOwner && !isLoggedInUserWinner &&
                  userProvider.isLoggedIn && !_showChatButton)
                Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: _showBidDialog,
                        child: Text('입찰'),
                      ),
                    ),
                  ],
                ),
              if (isLoggedInUserWinner)
                Column(
                  children: [
                    SizedBox(height: 30,),
                    Center(
                        child: Text("최종 상품 구매 대상자가 되셨습니다.")
                    ),
                    Center(
                        child: Text("진심으로 축하드립니다.🎉")
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final chatRoomId = getChatRoomId(
                              userProvider.id, widget.item.userId);
                          final lastMessage = chatProvider
                              .getLastMessageForChatRoom(chatRoomId);
                          chatProvider.createChatRoom(
                            userProvider.id,
                            userProvider.nickname,
                            widget.item.userId,
                            sellerNickname,
                            lastMessage ?? '',
                            widget.item.itemImage,
                          );
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(
                                  senderId: userProvider.id,
                                  recipientId: widget.item.userId,
                                  chatRoomId: chatRoomId,
                                  itemImage: widget.item.itemImage,
                                ),
                          ));
                        },
                        child: Text('판매자와 대화하기'),
                      ),
                    ),
                  ],
                ),
              if (!isLoggedInUserWinner && !isLoggedInUserSeller &&
                  _showChatButton)
                Center(
                  child: Text(
                    '경매 완료! 낙찰자는 $winnerNickname님입니다.👏',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
