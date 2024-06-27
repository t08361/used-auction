import 'package:flutter/material.dart';
import '../widgets/item_list.dart';
import '../screens/search_screen.dart';

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
    );
  }
}
