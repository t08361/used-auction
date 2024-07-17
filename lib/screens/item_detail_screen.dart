import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    remainingTime = widget.item.endDateTime.difference(DateTime.now());
    fetchBids(); // 입찰 기록 가져오기 호출
    fetchSellerNickname(); // 판매자의 닉네임 가져오기
    currentPrice = widget.item.lastPrice;
  }

  // 판매자의 닉네임 가져오기
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
        bids = bidList.map((bid) => {
          'nickname': bid['nickname'], // 입찰자의 닉네임
          'bidPrice': bid['bid']['bidAmount'] // 입찰 금액
        }).toList();
      });
    }else {
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
                  Text('입찰 금액: \$${currentPrice + widget.item.bidUnit * _currentBidStep}'),
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
                    final enteredBid = currentPrice + widget.item.bidUnit * _currentBidStep;
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


  void _handleMenuSelection(String value) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    //final userProvider = Provider.of<UserProvider>(context, listen: false);

    switch (value) {
      case 'edit'://수정
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ItemEditScreen(item: widget.item),
          ),
        );

        break;
      case 'delete'://삭제
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
    final userProvider = Provider.of<UserProvider>(context,listen:false);
    final chatProvider = Provider.of<ChatProvider>(context,listen:false);
    final itemProvider = Provider.of<ItemProvider>(context,listen:false);
    final bool isOwner = widget.item.userId == userProvider.id;
    //final sellerNickname = userProvider.getNicknameById(widget.item.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상품명 : '+widget.item.title,
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
              // 상품 이미지 추가 부분
              if (widget.item.itemImage != null && widget.item.itemImage!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      base64Decode(widget.item.itemImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '닉네임 : ' + sellerNickname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuSelection,
                    itemBuilder: (BuildContext context) {
                      if (isOwner&&userProvider.isLoggedIn) {
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
                '자세한 설명 : '+widget.item.description,
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
                '종료까지 남은 시간: ${remainingTime.inDays}일 ${remainingTime.inHours % 24}시간 ${remainingTime.inMinutes % 60}분',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                '입찰 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              bids.isEmpty
                ? const Text('아직 입찰 기록이 없습니다!', style: TextStyle(fontSize: 16, color: Colors.grey))
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
              if(!isOwner)
              Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: _showBidDialog,
                      child: Text('입찰'),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // 대화하기 눌렀을 때 userProvider.id와 item.userId에 대한 대화창이 열리게하는 버튼
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      //final itemProvider = Provider.of<ItemProvider>(context, listen: false);
                      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

                      final chatRoomId = getChatRoomId(userProvider.id, widget.item.userId);
                      final lastMessage = chatProvider.getLastMessageForChatRoom(chatRoomId);
                      chatProvider.createChatRoom(
                        userProvider.id,
                        userProvider.nickname,
                        widget.item.userId,
                        sellerNickname,
                        lastMessage ?? '',//채팅 마지막 내용이 들어가야함
                        userProvider.profileImage ?? '',
                      );
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          senderId: userProvider.id,
                          recipientId: widget.item.userId,
                          chatRoomId: chatRoomId,
                        ),
                      ));
                    },
                    child: Text('대화하기'),
                  ),
                ],
              ),
              if (isOwner)
                Center(
                  child: Text(
                    'You are the owner of this item.',
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
