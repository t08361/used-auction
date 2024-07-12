import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String recipientId;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.recipientId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadMessages(widget.senderId);
  }

  void _sendMessage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final message = ChatMessage(
      chatRoomId: _getChatRoomId(widget.senderId, widget.recipientId),
      senderId: widget.senderId,
      receiverId: widget.recipientId,
      message: _messageController.text,
      timestamp: DateTime.now(),
    );

    await chatProvider.sendMessage(message.chatRoomId,message.senderId,message.receiverId,message.message,message.timestamp);
    _messageController.clear();
  }

  String _getChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];
                final isMe = message.senderId == userProvider.id;
                return Container(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 10.0,right: 10.0, top: 10.0),
                  padding: EdgeInsets.only(left: 0.0, top: 10.0),
                  child: Text(
                    isMe ? '${message.timestamp.hour} : '+'${message.timestamp.minute}  '+message.message :
                    message.message + '  ${message.timestamp.hour} : '+'${message.timestamp.minute}  ',
                    style: TextStyle(
                      color: isMe ? Colors.blue : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: '메시지 입력',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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