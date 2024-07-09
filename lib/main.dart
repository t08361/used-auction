import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testhandproduct/providers/chat_provider.dart';
import 'providers/item_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/user_mypage.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/user_mypage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        //ChangeNotifierProvider(create: (context) => ChatProvider()), // 추가된 부분
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Provider.of<UserProvider>(context, listen: false).loadUser();

    return MaterialApp(
      title: '중고 거래 앱',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/user': (context) => UserPage(),
        '/home': (context) => HomeScreen(),
        '/add-item': (context) => AddItemScreen(),
        // Add other routes here
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions(BuildContext context) {
    return <Widget>[

      HomeScreen(),
      ChatListScreen(),
      Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return userProvider.isLoggedIn ? UserPage() : LoginScreen();
        },
      ),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions(context).elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}