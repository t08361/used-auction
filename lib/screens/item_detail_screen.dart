import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/user_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  // 임의로 설정한 현재가
  int currentPrice = 10000;
  // 종료까지 남은 시간 계산
  late Duration remainingTime;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.item.endDateTime.difference(DateTime.now());
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
            onPressed: () {
              final enteredBid = int.tryParse(_bidController.text);
              if (enteredBid != null && enteredBid >= currentPrice + widget.item.bidUnit) {
                setState(() {
                  currentPrice = enteredBid;
                });
                Navigator.of(ctx).pop();
              } else {
                // 유효하지 않은 입찰 금액에 대한 처리를 여기에 추가할 수 있습니다.
              }
            },
            child: Text('입찰'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 임의의 입찰 기록 리스트
    final List<Map<String, dynamic>> bids = [
      {'nickname': userProvider.nickname, 'bidPrice': 9000},
      {'nickname': '사용자2', 'bidPrice': 9500},
      {'nickname': '사용자3', 'bidPrice': currentPrice},
    ];

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
              // Image.file(
              //   widget.item.imageFile,
              //   width: double.infinity,
              //   height: 250,
              //   fit: BoxFit.cover,
              // ),
              const SizedBox(height: 10),
              const Text(
                '나눔이', // 여기에 실제 판매자 이름을 넣을 수 있습니다.
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
              Center(
                child: ElevatedButton(
                  onPressed: _showBidDialog,
                  child: Text('입찰'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
