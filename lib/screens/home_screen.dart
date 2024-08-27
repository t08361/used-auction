import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지 import
import '../providers/constants.dart'; // 상수값을 포함한 파일 import
import '../providers/item_provider.dart'; // 아이템 관련 상태 관리 Provider import
import '../widgets/item_list.dart'; // 아이템 리스트 위젯 import
import '../screens/search_screen.dart'; // 검색 화면 import
import '../screens/add_item_screen.dart'; // 아이템 추가 화면 import
import '../screens/notification_screen.dart'; // 알림 화면 import

// 앱바 부분(앱이름, 검색버튼, 알림버튼)
// 상품 리스트를 표시하는 영역 (widget/item_list.dart)
// 상품 등록 화면으로 이동하는 버튼

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 아이템 목록을 서버에서 가져오는 함수 호출
    Provider.of<ItemProvider>(context, listen: false).fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //앱바 부분(앱이름, 검색버튼, 알림버튼)
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // 원하는 높이로 설정
        child: AppBar(
          title: Text(
            '사종🔔', // 앱바 타이틀
            style: TextStyle(color: Colors.black), // 타이틀 색상 설정
          ),
          // 뒤로가기 버튼을 없애기
          automaticallyImplyLeading: false,
          elevation: 0, // 그림자 없애기
          backgroundColor: Colors.white, // 앱바 배경색 설정
          actions: [
            // 검색 기능 버튼
            IconButton(
              icon: const Icon(Icons.search), // 검색 아이콘
              color: Colors.black, // 아이콘 색상
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ItemSearch(), // 검색 위젯 호출
                );
              },
            ),
            // 알림을 볼 수 있는 버튼
            IconButton(
              icon: const Icon(Icons.notifications), // 알림 아이콘
              color: Colors.black, // 아이콘 색상
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(), // 알림 화면으로 이동
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.5), // 원하는 높이로 설정
            child: Container(
              color: Colors.grey, // 밑줄 색상
              height: 0.2, // 밑줄 두께
            ),
          ),
        ),
      ),
      // 상품 리스트를 표시하는 영역 (widget/item_list.dart)
      body: ItemList(),

      // 상품 등록 화면으로 이동하는 버튼
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white, // 아이콘 색상 설정
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddItemScreen()), // 아이템 추가 화면으로 이동
          );
        },
        backgroundColor: primary_color, // 버튼 배경색 설정
        child: const Icon(Icons.add), // 버튼 아이콘 설정
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 버튼 위치 설정
    );
  }
}
