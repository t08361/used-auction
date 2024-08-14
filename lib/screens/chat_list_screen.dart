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

    // 현재 사용자가 참여 중인 채팅방만 필터링( 수정해야할 부분 )
    final userChatRooms = chatProvider.chatRooms.where((chatRoom) =>
    chatRoom.sellerId == userProvider.id || chatRoom.buyerId == userProvider.id).toList();

    // 채팅방을 마지막 메시지 시간으로 정렬
    userChatRooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'), // 앱바 타이틀 설정
        centerTitle: false, // 타이틀을 왼쪽으로 정렬
        backgroundColor: Colors.white, // 앱바 배경색 설정
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5), // 원하는 높이로 설정
          child: Container(
            color: Colors.grey, // 밑줄 색상
            height: 0.2, // 밑줄 두께
          ),
        ),
      ),

      backgroundColor: Colors.white, // 배경색 설정

      // 🟡채팅방 리스트 Ui
      body: ListView.builder(
        itemCount: userChatRooms.length, // 채팅방 개수 설정
        itemBuilder: (context, index) {
          final chatRoom = userChatRooms[index];
          final isMe = chatRoom.sellerId == userProvider.id;
          final chatPartnerId = isMe ? chatRoom.buyerId : chatRoom.sellerId;
          final chatPartnerNickname = isMe ? chatRoom.buyerNickname : chatRoom.sellerNickname; // 실제로는 닉네임을 가져와야 함

          return Container(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(chatRoom.itemImage), // 상대방 프로필 이미지 사용
                radius: 24, // 원형 이미지의 반지름
              ),
              title: Text(chatPartnerNickname, style: TextStyle(color: Colors.black)), // 채팅 상대방 닉네임
              subtitle: Text(chatRoom.lastMessage, style: TextStyle(color: Colors.black)), // 마지막 메시지
              trailing: Text('${chatRoom.lastMessageTime.hour}:${chatRoom.lastMessageTime.minute}'), // 마지막 메시지 시간
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      senderId: userProvider.id,
                      recipientId: chatPartnerId,
                      chatRoomId: chatRoom.id,
                      itemImage: chatRoom.itemImage,
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