import 'package:flutter/material.dart';
import '../widgets/item_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('몽당마켓'),
      ),
      body: ItemList(),
    );
  }
}
