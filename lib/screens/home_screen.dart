import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: Color(0xFFE7F0DC),
      appBar: AppBar(
        title: const Text(
            '몽당마켓',
            style: TextStyle(color: Colors.white)
        ),
        automaticallyImplyLeading: false, // 뒤로가기 버튼을 없애기
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 72, 97, 62), // 앱 바 색
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              showSearch(
                context: context,
                delegate: ItemSearch(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ItemList(),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 72, 97, 62),
        child: const Icon(Icons.add), // 버튼 배경 색상 변경
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 버튼 위치 설정
    );
  }
}