import 'package:flutter/material.dart';
import '../widgets/item_list.dart';
import '../screens/search_screen.dart';
import '../screens/add_item_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '몽당마켓',
            style: TextStyle(color: Colors.black)
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.black,
            onPressed: () {
              showSearch(
                context: context,
                delegate: ItemSearch(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.black,
            onPressed: () {

            },
          ),
        ],
      ),
      body: ItemList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red, // 버튼 배경 색상 변경
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 버튼 위치 설정
    );
  }
}
