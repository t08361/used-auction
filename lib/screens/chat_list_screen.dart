import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chatRoom.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 목록'),
      ),
      body: ListView.builder(
        itemCount: chatProvider.chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatProvider.chatRooms[index];
          final isMe = chatRoom.sellerId == userProvider.id;
          final chatPartnerId = isMe ? chatRoom.buyerId : chatRoom.sellerId;
          final chatPartnerNickname = isMe ? chatRoom.buyerNickname : chatRoom.sellerNickname; // 실제로는 닉네임을 가져와야 함

          return Container(
            color: Colors.green[200], // 배경색 설정
            child: ListTile(
              //leading: Image.network(chatRoom.itemImage),
              title: Text(chatPartnerNickname),
              subtitle: Text(chatRoom.lastMessage),
              //trailing: Text(’${chatRoom.lastMessageTime}’), // 포맷팅 필요
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      senderId: userProvider.id,
                      recipientId: chatPartnerId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}