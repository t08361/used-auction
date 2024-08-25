import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지 import
import 'package:testhandproduct/providers/constants.dart'; // 앱의 상수값을 포함한 파일 import
import '../providers/chat_provider.dart'; // 채팅 관련 상태 관리 Provider import
import '../providers/user_provider.dart'; // 사용자 관련 상태 관리 Provider import
import '../models/chatRoom.dart'; // 채팅방 모델 import
import 'chat_screen.dart'; // 채팅 화면 import

//함수 구성
// 채팅방 목록 로드 함수
// 채팅방 ID 생성 함수

// 🟡채팅방 리스트 Ui


class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  @override
  void initState() {
    super.initState();
    _loadChatRooms(); // 채팅방 목록 로드
  }

  // 채팅방 목록 로드 함수
  void _loadChatRooms() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadChatRooms(); // 채팅방 목록을 로드
  }

  // 채팅방 ID 생성 함수
  String getChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort(); // 유저 ID 정렬
    return sortedIds.join('_'); // 정렬된 ID를 조합하여 채팅방 ID 생성
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // 현재 사용자가 참여 중인 채팅방만 필터링
    final userChatRooms = chatProvider.chatRooms.where((chatRoom) =>
    chatRoom.sellerId == userProvider.id || chatRoom.buyerId == userProvider.id).toList();

    // 상태 확인용 로그 출력
    print("User Chat Rooms: ${userChatRooms.length}");

    userChatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        centerTitle: false,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(
            color: Colors.grey,
            height: 0.2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: userChatRooms.isEmpty
          ? Center(
        child: Text(
          "채팅방이 없습니다.",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      )
          : ListView.builder(
        itemCount: userChatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = userChatRooms[index];
          final isMe = chatRoom.sellerId == userProvider.id;
          final chatPartnerId = isMe ? chatRoom.buyerId : chatRoom.sellerId;
          final chatPartnerNickname = isMe ? chatRoom.buyerNickname : chatRoom.sellerNickname;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chatRoom.itemImage),
              radius: 24,
            ),
            title: Text(chatPartnerNickname, style: TextStyle(color: Colors.black)),
            subtitle: Text(chatRoom.lastMessage, style: TextStyle(color: Colors.black)),
            trailing: Text('${chatRoom.lastMessageTime.hour}:${chatRoom.lastMessageTime.minute}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    senderId: userProvider.id,
                    recipientId: chatPartnerId,
                    chatRoomId: chatRoom.id,
                    itemImage: chatRoom.itemImage,
                      finalPrice: chatRoom.finalPrice,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}