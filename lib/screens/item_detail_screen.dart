import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import '../providers/constants.dart';
import 'package:http/http.dart' as http;

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int currentPrice = 10000; // 임의로 설정한 현재가
  late Duration remainingTime; // 종료까지 남은 시간 계산
  List<Map<String, dynamic>> bids = []; // 현재 입찰 기록을 담을 리스트

  @override
  void initState() {
    super.initState();
    remainingTime = widget.item.endDateTime.difference(DateTime.now());
    fetchBids(); // 입찰 기록 가져오기 호출
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
      fetchBids(); // 입찰 성공 후 입찰 기록 다시 가져오기
      print('입찰 성공!');
      print('bidData: $bidData');
    } else {
      print('입찰 실패: ${response.body}');
    }
  }

  // 입찰 버튼을 눌렀을 때 호출되는 함수
  void _showBidDialog() {
    final _bidController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('입찰하기'),
        content: TextField(
          controller: _bidController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '입찰 금액'),
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
              final enteredBid = int.tryParse(_bidController.text);
              if (enteredBid != null && enteredBid >= currentPrice + widget.item.bidUnit) {
                setState(() {
                  currentPrice = enteredBid;
                });
                await _placeBid(enteredBid); // 백엔드로 입찰 정보 전송
                Navigator.of(ctx).pop();
              } else {
                // 유효하지 않은 입찰 금액에 대한 처리를 여기에 추가
              }
            },
            child: Text('입찰'),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    switch (value) {
      case 'edit':
      // 수정하기 기능 추가
        break;
      case 'delete':
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context);
    final bool isOwner = widget.item.userId == userProvider.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item.title,
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
                  const Text(
                    '나눔이', // 여기에 실제 판매자 이름을 넣을 수 있습니다.
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    onSelected: _handleMenuSelection,
                    itemBuilder: (BuildContext context) {
                      if (isOwner) {
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
                widget.item.description,
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
              Center(
                child: ElevatedButton(
                  onPressed: _showBidDialog,
                  child: Text('입찰'),
                ),
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
