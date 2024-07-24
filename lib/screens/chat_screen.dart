import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String recipientId;
  final String chatRoomId;
  final String itemImage;

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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadRecipientProfileImage();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(widget.chatRoomId);
    _scrollToBottom();
  }

  Future<void> _loadRecipientProfileImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileImage = await userProvider.getProfileImageById(widget.recipientId);
    setState(() {
      _buyerProfileImage = profileImage;
    });
  }

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
            CircleAvatar(
              // 상품 이미지
              backgroundImage: NetworkImage(widget.itemImage),
              radius: 22,
            ),
            SizedBox(width: 100),
            Text(
              '낙찰가 : 20000원',
              style: TextStyle(
                color: Color(0xFF36BA98), // 텍스트 색상 설정
                fontWeight: FontWeight.bold,
                fontSize: 18, // 텍스트 크기 설정),
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF36BA98), // 뒤로가기 버튼 색상 변경
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
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
                    margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
                    padding: EdgeInsets.only(left: 0.0, top: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe && !isLastMessageFromSameUser) ...[
                          CircleAvatar(
                            backgroundImage: _buyerProfileImage != null
                                ? NetworkImage(_buyerProfileImage!)
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,
                            radius: 15,
                          ),
                          SizedBox(width: 10),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white : Colors.white,
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
                          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10),
                          constraints: BoxConstraints(maxWidth: 250), // 최대 너비 설정
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
                                    backgroundColor: isMe ? Colors.white : Colors.white,
                                    color: Colors.black,
                                  ),
                                ),
                                if (!isLastMessageFromSameUser) ...[
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
                            softWrap: true,
                          ),
                        ),
                        if (isMe && !isLastMessageFromSameUser) ...[
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: userProvider.profileImage != null
                                ? NetworkImage(userProvider.profileImage!)
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,
                            radius: 15,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 버튼을 눌렀을 때의 동작을 정의
                        print('Button Pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color(0xFF36BA98), // 버튼 텍스트 색상
                        padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5), // 버튼 패딩 설정
                      ),
                      child: Text(
                        '거래\n완료',
                        textAlign: TextAlign.center, // 텍스트 정렬 설정
                        style: TextStyle(
                          fontSize: 14, // 텍스트 크기 설정
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: '메시지 입력',
                        labelStyle: TextStyle(
                          color: Colors.black, // 레이블 텍스트 색상 설정
                          fontSize: 18, // 레이블 텍스트 크기 설정
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        //color: Colors.green, // 입력된 텍스트 색상 설정
                        fontSize: 16, // 입력된 텍스트 크기 설정
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
