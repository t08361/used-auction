import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chatRoom.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadChatRooms();
  }

  String getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // 현재 사용자가 참여 중인 채팅방만 필터링
    final userChatRooms = chatProvider.chatRooms.where((chatRoom) =>
    chatRoom.sellerId == userProvider.id || chatRoom.buyerId == userProvider.id).toList();

    // 채팅방을 마지막 메시지 시간으로 정렬
    userChatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        centerTitle: false, // 타이틀을 왼쪽으로 정렬
      ),
      body: ListView.builder(
        itemCount: userChatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = userChatRooms[index];
          final isMe = chatRoom.sellerId == userProvider.id;
          final chatPartnerId = isMe ? chatRoom.buyerId : chatRoom.sellerId;
          final chatPartnerNickname = isMe ? chatRoom.buyerNickname : chatRoom.sellerNickname; // 실제로는 닉네임을 가져와야 함

          return Container(
            //color: Colors.green[200], // 배경색 설정
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chatRoom.itemImage), // 이미지 URL을 chatRoom.itemImage로 대체
                radius: 24, // 원형 이미지의 반지름
                //backgroundColor: Colors.grey[200], // 이미지가 로드되기 전에 보여질 배경색
              ),
              title: Text(chatPartnerNickname,style: TextStyle(color: Colors.black),),
              subtitle: Text(chatRoom.lastMessage,style: TextStyle(color: Colors.black),),
              trailing: Text('${chatRoom.lastMessageTime.hour}:${chatRoom.lastMessageTime.minute}'), // 포맷팅 필요
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      senderId: userProvider.id,
                      recipientId: chatPartnerId,
                      chatRoomId: chatRoom.id,
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