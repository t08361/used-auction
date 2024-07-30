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
import 'login_screen.dart';
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
  //String sellerImageUrl = ''; // 판매자의 이미지 URL
  bool _showChatButton = false; // 대화하기 버튼을 표시할지 여부를 담는 변수
  Timer? _timer; // 남은 시간을 지속적으로 업데이트하기 위한 타이머
  String winnerId = ''; // 가장 높은 입찰가를 제시한 사용자의 ID를 저장할 변수
  String winnerNickname = ''; // 낙찰자의 닉네임
  bool _showAllBids = false; // 모든 입찰 기록을 보여줄지 여부를 담는 변수
  bool _isLoading = true; // 로딩 상태를 나타내는 변수
  bool _showPrice = false; // 판매 가격을 보여줄지 여부를 담는 변수
  bool _showCurrentPrice = false;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.item.endDateTime.difference(DateTime.now());
    fetchBids().then((_) {
      setState(() {
        _isLoading = false; // 입찰 기록을 가져온 후 로딩 상태를 false로 설정
      });
    });
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

    // 2초 후에 showPrice를 true로 설정
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showPrice = true;
      });
    });

    Timer(const Duration(milliseconds: 20), () {
      setState(() {
        _showCurrentPrice = true;
      });
    });
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

  // // 판매자의 닉네임과 이미지 정보 가져오기
  // Future<void> fetchSellerDetails() async {
  //   final url = Uri.parse('$baseUrl/users/${widget.item.userId}');
  //   final response = await http.get(url);
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> user = json.decode(response.body);
  //     setState(() {
  //       sellerImageUrl = user['imageUrl']; // 이미지 URL 가져오기
  //     });
  //     print('판매자 닉네임 : $sellerNickname');
  //   } else {
  //     print('판매자 정보 가져오기 실패');
  //   }
  // }

  // 현재 상품의 입찰 기록을 가져오기
  Future<void> fetchBids() async {
    final url = Uri.parse('$baseUrl/bids/${widget.item.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> bidList = json.decode(response.body);
      setState(() {
        bids = bidList
            .map((bid) => {
                  'nickname': bid['nickname'], // 입찰자의 닉네임
                  'bidPrice': bid['bid']['bidAmount'], // 입찰 금액
                  'bidderId': bid['bid']['bidderId'], // 입찰자 ID 추가
                })
            .toList();
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


//사진 전체화면에 보여지는 경우 설정
  void _showFullImage(List<String> imageUrls, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  controller: PageController(initialPage: initialIndex),
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      clipBehavior: Clip.none,
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 전체 입찰 기록을 팝업으로 보여주는 함수
  void _showAllBidsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              AppBar(
                title: const Text('전체 입찰 기록',
                    style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                elevation: 0,
              ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: bids.length,
                  itemBuilder: (ctx, index) {
                    final bid = bids[index];
                    return ListTile(
                      title: Text(bid['nickname'] as String),
                      subtitle: Text('제안 가격 : \$${bid['bidPrice']}'),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showAllBids = false;
                  });
                },
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _showAllBids = false;
      });
    });
  }

  // 입찰 기록을 보여주는 부분
  Widget _buildBidList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator()); // 로딩 중일 때 표시할 인디케이터
    }

    // bids 리스트를 역순으로 정렬하고 상위 3개 항목을 선택
    final bidsToShow = _showAllBids ? bids : bids.reversed.take(3).toList();

    return Column(
      children: [
        bidsToShow.isEmpty
            ? const Text('아직 입찰 기록이 없습니다!',
                style: TextStyle(fontSize: 16, color: Colors.grey))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bidsToShow.length,
                itemBuilder: (ctx, index) {
                  final bid = bidsToShow[index];
                  return ListTile(
                    title: Text(bid['nickname'] as String),
                    subtitle: Text('입찰가: \$${bid['bidPrice']}'),
                  );
                },
              ),
      ],
    );
  }

  // 이미지 슬라이더를 추가하는 부분
  Widget _buildImageSlider() {
    return GestureDetector(
      onTap: () => _showFullImage(widget.item.itemImages, 0),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.item.itemImages.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.network(
                    widget.item.itemImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.zero, topRight: Radius.circular(13)),
                  ),
                  child: Text(
                    '남은 시간: ${remainingTime.inDays}일 ${remainingTime.inHours % 24}시간 ${remainingTime.inMinutes % 60}분 ${remainingTime.inSeconds % 60}초',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
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
                  Text(
                    '제안할 금액: \₩${currentPrice + widget.item.bidUnit * _currentBidStep}',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  Text('현재가: \₩${currentPrice}'),
                  const SizedBox(height: 10),
                  NumberPicker(
                    minValue: 1,
                    maxValue: 200,
                    value: _currentBidStep,
                    onChanged: (value) {
                      setState(() {
                        _currentBidStep = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('입찰 단위: \$${widget.item.bidUnit}'),
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
                    final enteredBid =
                        currentPrice + widget.item.bidUnit * _currentBidStep;
                    setState(() {
                      currentPrice = enteredBid;
                    });
                    await _placeBid(enteredBid); // 백엔드로 입찰 정보 전송
                    Navigator.of(ctx).pop();
                    setState(() {
                      _showCurrentPrice = false; // 먼저 텍스트를 숨김
                    });
                    // 짧은 지연 후 텍스트를 다시 표시하여 애니메이션 효과를 줍니다.
                    Timer(Duration(milliseconds: 100), () {
                      setState(() {
                        _showCurrentPrice = true;
                      });
                    });
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
      final highestBid = bids.reduce(
          (curr, next) => curr['bidPrice'] > next['bidPrice'] ? curr : next);
      final highestBidAmount = highestBid['bidPrice'];
      final highestBidderId =
          highestBid['bidderId'] ?? ''; // Null일 경우 빈 문자열로 처리
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
    } else {
      print('낙찰가 업데이트 실패: ${response.body}');
    }
  }

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
          if (winnerId.isNotEmpty &&
              widget.item.userId != winnerId &&
              userProvider.id == winnerId) {
            // 낙찰자가 있는 경우에만 채팅방 생성
            final chatRoomId =
                getChatRoomId(userProvider.id, widget.item.userId);
            final lastMessage =
                chatProvider.getLastMessageForChatRoom(chatRoomId);
            chatProvider.createChatRoom(
              userProvider.id,
              userProvider.nickname,
              widget.item.userId,
              sellerNickname,
              lastMessage ?? '',
              widget.item.itemImages.isNotEmpty
                  ? widget.item.itemImages[0]
                  : '',
            );
          }
        }
      });
    });
  }

  Widget buildPopupMenuButton(bool isOwner, bool isLoggedIn) {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (BuildContext context) {
        if (isOwner && isLoggedIn) {
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
    );
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

  //🔴메인 코드 시작
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
        title: Row(
          children: [
            Text(

                  sellerNickname +

                  ' 님의 상품',
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상을 검은색으로 설정
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(), // 이미지 슬라이더 추가
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.item.title,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        buildPopupMenuButton(isOwner, userProvider.isLoggedIn),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item.region, // 주소를 표시하는 Text 위젯 추가
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    if (isLoggedInUserWinner ||
                        (!isLoggedInUserWinner &&
                            !isLoggedInUserSeller &&
                            _showChatButton))
                      // AnimatedOpacity 추가
                      AnimatedOpacity(
                        opacity: _showCurrentPrice ? 1.0 : 0.0,
                        duration: Duration(seconds: 1),
                        child: Text(
                          '현재 가격 : ${currentPrice}원',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (isLoggedInUserWinner ||
                        (!isLoggedInUserWinner &&
                            !isLoggedInUserSeller &&
                            _showChatButton))
                      const SizedBox(height: 10),
                    if (isLoggedInUserWinner ||
                        (!isLoggedInUserWinner &&
                            !isLoggedInUserSeller &&
                            _showChatButton))
                      AnimatedOpacity(
                        opacity: _showCurrentPrice ? 1.0 : 0.0,
                        duration: Duration(seconds: 4),
                        child: Text(
                          '시작 가격 : ${widget.item.price}원',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      '설명 : ' + widget.item.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          '입찰 기록',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (bids.length > 3 && !_showAllBids)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllBids = true;
                              });
                              _showAllBidsDialog();
                            },
                            child: const Text('더보기'),
                          ),
                      ],
                    ),
                    _buildBidList(), // 입찰 기록 리스트 추가
                  ]),
            ),
          ],
        ),
      ),

      //🟣 하단 앱바
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          children: [
            if (!userProvider.isLoggedIn)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
                          foregroundColor:
                              primary_color, // 글자색을 primary_color로 설정
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40), // 패딩 조절
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // 모서리 둥글기
                            side: BorderSide(color: primary_color), // 테두리 색상 설정
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                        },
                        icon: Icon(Icons.login, color: primary_color), // 아이콘 추가
                        label: Text(
                          '로그인 해주세요',
                          style: TextStyle(
                              color: primary_color), // 글자색을 primary_color로 설정
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (userProvider.isLoggedIn)
              Column(
                children: [
                  if (!(isLoggedInUserWinner ||
                      (!isLoggedInUserWinner &&
                          !isLoggedInUserSeller &&
                          _showChatButton)))
                    SizedBox(
                      width: 200,
                    ),
                  if ((isLoggedInUserWinner ||
                      (!isLoggedInUserWinner &&
                          !isLoggedInUserSeller &&
                          _showChatButton)))
                    SizedBox(
                      width: 30,
                    ),
                  if (!(isLoggedInUserWinner ||
                      (!isLoggedInUserWinner &&
                          !isLoggedInUserSeller &&
                          _showChatButton)))
                    // AnimatedOpacity 추가
                    AnimatedOpacity(
                      opacity: _showCurrentPrice ? 1.0 : 0.0,
                      duration: Duration(seconds: 1),
                      child: Text(
                        '현재 가격 : ${currentPrice}원',
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (!(isLoggedInUserWinner ||
                      (!isLoggedInUserWinner &&
                          !isLoggedInUserSeller &&
                          _showChatButton)))
                    AnimatedOpacity(
                      opacity: _showCurrentPrice ? 1.0 : 0.0,
                      duration: Duration(seconds: 4),
                      child: Text(
                        '시작 가격 : ${widget.item.price}원',
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    ),
                ],
              ),
            if (userProvider.isLoggedIn &&
                !(isLoggedInUserWinner ||
                    (!isLoggedInUserWinner &&
                        !isLoggedInUserSeller &&
                        _showChatButton)))
              Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (userProvider.isLoggedIn && isLoggedInUserSeller)
                  Center(
                    child: Text(
                      '내가 등록한 상품',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                if (userProvider.isLoggedIn &&
                    !isOwner &&
                    !isLoggedInUserWinner &&
                    !userProvider.isLoggedIn &&
                    !_showChatButton)
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
                if (userProvider.isLoggedIn &&
                    !isOwner &&
                    !isLoggedInUserWinner &&
                    userProvider.isLoggedIn &&
                    !_showChatButton)
                  Column(
                    children: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary_color, // 배경색
                            foregroundColor: Colors.white, // 글자색
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20), // 패딩 조절
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 모서리 둥글기
                            ),
                          ),
                          onPressed: _showBidDialog,
                          child: Text('입찰'),
                        ),
                      ),
                    ],
                  ),
                if (userProvider.isLoggedIn && isLoggedInUserWinner)
                  Row(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Center(child: Text("최종 상품 구매 대상자가 되셨습니다.")),
                          Center(child: Text("진심으로 축하드립니다.🎉")),
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary_color, // 배경색
                              foregroundColor: Colors.white, // 글자색
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20), // 패딩 조절
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8), // 모서리 둥글기
                              ),
                            ),
                            onPressed: () async {
                              final chatRoomId = getChatRoomId(
                                  userProvider.id, widget.item.userId);
                              final lastMessage = chatProvider
                                  .getLastMessageForChatRoom(chatRoomId);
                              if (winnerId.isNotEmpty &&
                                  widget.item.userId != winnerId &&
                                  userProvider.id == winnerId)
                                chatProvider.createChatRoom(
                                  userProvider.id,
                                  userProvider.nickname,
                                  widget.item.userId,
                                  sellerNickname,
                                  lastMessage ?? '',
                                  widget.item.itemImages.isNotEmpty
                                      ? widget.item.itemImages[0]
                                      : '',
                                );
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  senderId: userProvider.id,
                                  recipientId: widget.item.userId,
                                  chatRoomId: chatRoomId,
                                  itemImage: widget.item.itemImages.isNotEmpty
                                      ? widget.item.itemImages[0]
                                      : '',
                                ),
                              ));
                            },
                            child: Text('대화하기'),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (userProvider.isLoggedIn &&
                    !isLoggedInUserWinner &&
                    !isLoggedInUserSeller &&
                    _showChatButton)
                  Center(
                    child: Text(
                      '경매 완료! 낙찰자는 $winnerNickname님입니다.👏',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
              ],
            ),
            SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
    );
  }
}
