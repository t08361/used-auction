import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String recipientId;
  final String chatRoomId;  // chatRoomId 추가

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.recipientId,
    required this.chatRoomId, // chatRoomId 추가
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(widget.chatRoomId); // chatRoomId 사용
    _scrollToBottom();
  }

  void _sendMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final message = ChatMessage(
      id: '', // id는 서버에서 생성
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('상품이미지//'),
            SizedBox(width: 10),
            Text('낙찰가 : 20000원'),
          ],
        ),
      ),
      body: Container(
        color: Colors.yellow[100], // 바디 부분의 배경색 변경
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  final isMe = message.senderId == userProvider.id;
                  final bool isLastMessageFromSameUser = index < chatProvider.messages.length - 1 &&
                      chatProvider.messages[index + 1].senderId == message.senderId &&
                      chatProvider.messages[index + 1].timestamp.difference(message.timestamp).inMinutes == 0;

                  return Container(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 6.0, right: 6.0, top: 10.0),
                    padding: EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMe ? Colors.lightGreenAccent : Colors.yellowAccent, // 배경색 설정
                        borderRadius: isMe
                            ? BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                        )
                            : BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ), // 모서리 다르게 설정
                      ),
                      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10), // 텍스트 주위에 여백
                      child: RichText(
                        text: TextSpan(
                          children: [
                            if (!isLastMessageFromSameUser) ...[
                              TextSpan(
                                text: isMe ? '${message.timestamp.hour}:${message.timestamp.minute}   ' : '',
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
                                backgroundColor: isMe ? Colors.lightGreenAccent : Colors.yellowAccent,
                                color: Colors.black, //텍스트 색깔 설정
                              ),
                            ),
                            if (isLastMessageFromSameUser) ...[
                              TextSpan(
                                text: isMe ? '' : '  ${message.timestamp.hour}:${message.timestamp.minute}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: '메시지 입력',
                        border: InputBorder.none, // 밑줄 제거
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
      ),
    );
  }
}