import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testhandproduct/providers/chat_provider.dart';
import 'package:testhandproduct/providers/constants.dart';
import 'providers/item_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/user_mypage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩 초기화
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()), // 추가된 부분
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
      backgroundColor: primary_color, // Scaffold 배경색 설정
      body: _widgetOptions(context).elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        // height: 90, // 원하는 높이로 설정
        decoration: const BoxDecoration(
          color: Colors.white, // 하단바 배경색을 하얗게 설정
          border: Border(
            top: BorderSide(
              color: Colors.grey, // 경계선 색을 설정
              width: 0.2, // 경계선 너비를 설정
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_outlined),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '마이페이지',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: primary_color,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // 네비게이션 바의 배경색 설정
        ),
      ),
    );
  }
}