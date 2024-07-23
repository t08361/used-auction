import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/constants.dart';
import '../providers/item_provider.dart';
import '../widgets/item_list.dart';
import '../screens/search_screen.dart';
import '../screens/add_item_screen.dart';
import '../screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<ItemProvider>(context, listen: false).fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0), // 원하는 높이로 설정
        child: AppBar(
          automaticallyImplyLeading: false,
          // 뒤로가기 버튼을 없애기
          elevation: 0,
          backgroundColor: Colors.white,
          // 앱 바 색
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.black,
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ItemSearch(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              color: Colors.black,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.5), // 원하는 높이로 설정
            child: Container(
              color: Colors.grey, // 밑줄 색상
              height: 0.4, // 밑줄 두께
            ),
          ),
        ),
      ),
      body: ItemList(),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
        backgroundColor: primary_color,
        child: const Icon(Icons.add), // 버튼 배경 색상 변경
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 버튼 위치 설정
    );
  }
}
