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
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _buyerProfileImage;
  Timer? _timer;
  bool _initialScrollDone = false;
  bool _isRecipientValid = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  // 메시지 로드 함수
  Future<void> _initializeChat() async {
    try {
      await _loadMessages(); // 메시지 로드
      await _loadRecipientProfileImage(); // 프로필 이미지 로드
      _isRecipientValid = await _isRecipientValidCheck(); // 상대방 상태 확인

      if (_isRecipientValid) {
        _startTimer(); // 상대방이 유효한 경우에만 타이머 시작
      } else {
        _addRecipientInvalidMessage(); // 상대방이 탈퇴한 경우 메시지 추가
      }
    } catch (e) {
      print('Chat initialization error: $e');
    }
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      await chatProvider.loadMessages(widget.chatRoomId);
      if (!_initialScrollDone) {
        _scrollToBottom();
        _initialScrollDone = true;
      }
    } catch (e) {
      print('Error loading messages: $e');
      throw Exception('Failed to load messages');
    }
  }

  // 받는 사람 프로필 이미지 로드 함수
  Future<void> _loadRecipientProfileImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final profileImage = await userProvider.getProfileImageById(widget.recipientId);
      setState(() {
        _buyerProfileImage = profileImage;
      });
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<bool> _isRecipientValidCheck() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      return await userProvider.doesUserExist(widget.recipientId);
    } catch (e) {
      print('Error checking recipient validity: $e');
      return false; // 기본적으로 유효하지 않다고 설정
    }
  }

  void _addRecipientInvalidMessage() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final systemMessage = ChatMessage(
      id: '', // 임시 ID
      chatRoomId: widget.chatRoomId,
      senderId: 'system', // 시스템 메시지로 구분
      recipientId: widget.senderId,
      content: '상대방이 탈퇴하여 현재 채팅방을 이용할 수 없습니다.',
      timestamp: DateTime.now(),
    );

    chatProvider.messages.add(systemMessage);
    setState(() {
      _scrollToBottom();
    });
  }

  // 타이머 시작 함수
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await _loadMessages();
      } catch (e) {
        print('Error reloading messages: $e');
      }
    });
  }

  // 메시지 전송 함수
  void _sendMessage() async {
    if (!_isRecipientValid) {
      return; // 상대방이 유효하지 않으면 메시지 전송을 막음
    }

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
          duration: const Duration(milliseconds: 100),
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
            const SizedBox(width: 20),
            const Text(
              '낙찰가 : 20000원',
              style: TextStyle(
                color: Color(0xFF36BA98),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF36BA98),
        ),
        backgroundColor: Colors.white,
      ),
      // 채팅방 바디 화면 부분
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 메시지 리스트 표시
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                final isSystemMessage = message.senderId == 'system';

                bool showTime = true;
                bool showProfile = true;

                if (index < chatProvider.messages.length - 1 &&
                    chatProvider.messages[index + 1].timestamp.hour == message.timestamp.hour &&
                    chatProvider.messages[index + 1].timestamp.minute == message.timestamp.minute &&
                    chatProvider.messages[index + 1].senderId == message.senderId) {
                  showTime = false;
                }

                if (index < chatProvider.messages.length - 1 &&
                    chatProvider.messages[index + 1].senderId == message.senderId &&
                    chatProvider.messages[index + 1].timestamp.hour == message.timestamp.hour &&
                    chatProvider.messages[index + 1].timestamp.minute == message.timestamp.minute) {
                  showProfile = false;
                }

                return Container(
                  alignment: isSystemMessage
                      ? Alignment.center
                      : (message.senderId == userProvider.id
                      ? Alignment.centerRight
                      : Alignment.centerLeft),
                  margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 5.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: isSystemMessage
                      ? Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.senderId != userProvider.id && showProfile) ...[
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
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: message.senderId == userProvider.id
                                      ? const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                  )
                                      : const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                constraints: const BoxConstraints(maxWidth: 250),
                                child: Text(
                                  message.content,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (message.senderId != userProvider.id && showTime) ...[
                                const SizedBox(width: 5),
                                Text(
                                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      if (message.senderId == userProvider.id && showProfile) ...[
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundImage: userProvider.profileImage != null
                              ? NetworkImage(userProvider.profileImage!)
                              : const AssetImage(
                              'assets/images/default_profile.png')
                          as ImageProvider,
                          radius: 15,
                        ),
                      ] else if (message.senderId == userProvider.id) ...[
                        const SizedBox(width: 40), // 프로필 공간 확보
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
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: '메시지 입력',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _isRecipientValid ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
