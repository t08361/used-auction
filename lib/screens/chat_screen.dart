import 'dart:async'; // 타이머 관련 라이브러리
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import '../providers/chat_provider.dart'; // 채팅 관련 상태 관리 Provider
import '../providers/user_provider.dart'; // 사용자 관련 상태 관리 Provider
import '../models/chatMessage.dart'; // 채팅 메시지 모델

//함수 구성
// 메시지 로드 함수
// 받는 사람 프로필 이미지 로드 함수
// 타이머 시작 함수
// 메시지 전송 함수
// 처음에 화면 켜지면 제일 아래로 화면 스크롤 하는 험수

// 🟡화면 Ui
// 채팅방 상단 앱바 부분
// 채팅방 바디 화면 부분
// 🟢메세지 입력창

class ChatScreen extends StatefulWidget {
  final String senderId; // 보낸 사람 ID
  final String recipientId; // 받는 사람 ID
  final String chatRoomId; // 채팅방 ID
  final String itemImage; // 아이템 이미지 URL

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.recipientId,
    required this.chatRoomId,
    required this.itemImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController(); // 메시지 입력 컨트롤러
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러
  String? _buyerProfileImage; // 구매자 프로필 이미지
  Timer? _timer; // 타이머
  bool _initialScrollDone = false; // 스크롤이 초기화되었는지 여부

  @override
  void initState() {
    super.initState();
    _loadMessages(); // 메시지 로드
    _loadRecipientProfileImage(); // 받는 사람 프로필 이미지 로드
    _startTimer(); // 타이머 시작
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  // 메시지 로드 함수
  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(widget.chatRoomId);
    if (!_initialScrollDone) {
      _scrollToBottom(); // 초기 스크롤 위치 설정
      _initialScrollDone = true; // 초기화 완료 설정
    }
  }

  // 받는 사람 프로필 이미지 로드 함수
  Future<void> _loadRecipientProfileImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileImage =
        await userProvider.getProfileImageById(widget.recipientId);
    setState(() {
      _buyerProfileImage = profileImage;
    });
  }

  // 타이머 시작 함수
  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _loadMessages(); // 상태를 갱신할 필요 없음
    });
  }

  // 메시지 전송 함수
  void _sendMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final message = ChatMessage(
      id: '',
      chatRoomId: widget.chatRoomId,
      senderId: widget.senderId,
      recipientId: widget.recipientId,
      content: _messageController.text,
      timestamp: DateTime.now(),
    );

    await chatProvider.sendMessage(
      message.chatRoomId,
      message.senderId,
      message.recipientId,
      message.content,
      message.timestamp,
    );
    _messageController.clear();
    _scrollToBottom();
  }

  // 처음에 화면 켜지면 제일 아래로 화면 스크롤 하는 기능
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🟡화면 Ui
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      // 채팅방 상단 앱바 부분
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.itemImage),
              radius: 22,
            ),
            SizedBox(width: 20), // 크기 조정
            Text(
              '낙찰가 : 20000원',
              style: TextStyle(
                color: Color(0xFF36BA98),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF36BA98),
        ),
        backgroundColor: Colors.white,
      ),
      // 채팅방 바디 화면 부분
      body: Column(
        children: [
          // 메시지 리스트 표시
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                final isMe = message.senderId == userProvider.id;
                final bool isLastMessageFromSameUser =
                    index < chatProvider.messages.length - 1 &&
                        chatProvider.messages[index + 1].senderId ==
                            message.senderId &&
                        chatProvider.messages[index + 1].timestamp
                                .difference(message.timestamp)
                                .inMinutes ==
                            0;

                return Container(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
                  // 상하단 간격 조정
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  // 상하단 간격 조정
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isMe && !isLastMessageFromSameUser) ...[
                        CircleAvatar(
                          backgroundImage: _buyerProfileImage != null
                              ? NetworkImage(_buyerProfileImage!)
                              : AssetImage('assets/images/default_profile.png')
                                  as ImageProvider,
                          radius: 15,
                        ),
                        SizedBox(width: 10),
                      ] else if (!(isMe && !isLastMessageFromSameUser)) ...[
                        SizedBox(width: 40),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: isMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                )
                              : BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                  bottomRight: Radius.circular(30.0),
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: isMe ? 1 : 0,
                              blurRadius: isMe ? 3 : 0,
                              offset: isMe ? Offset(0, 3) : Offset(0, 0),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        constraints: BoxConstraints(maxWidth: 250),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (!isLastMessageFromSameUser) ...[
                                TextSpan(
                                  text: isMe
                                      ? '${message.timestamp.hour}:${message.timestamp.minute}   '
                                      : '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                              TextSpan(
                                text: message.content,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              if (!isLastMessageFromSameUser) ...[
                                TextSpan(
                                  text: isMe
                                      ? ''
                                      : '  ${message.timestamp.hour}:${message.timestamp.minute}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (isMe && !isLastMessageFromSameUser) ...[
                        SizedBox(width: 10),
                        CircleAvatar(
                          backgroundImage: userProvider.profileImage != null
                              ? NetworkImage(userProvider.profileImage!)
                              : AssetImage('assets/images/default_profile.png')
                                  as ImageProvider,
                          radius: 15,
                        ),
                      ] else if (!(isMe && !isLastMessageFromSameUser)) ...[
                        SizedBox(width: 40),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // 🟢메세지 입력창
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: '메시지 입력',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
