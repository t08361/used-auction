import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // 권한 요청 함수 호출
  await requestPermissions();

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

// 처음에 화면 들어오면 사용자 권한 설정 받는 함수
Future<void> requestPermissions() async {
  // 위치 권한 요청
  PermissionStatus locationStatus = await Permission.locationWhenInUse.request();

  // 알림 권한 요청 (iOS의 경우)
  PermissionStatus notificationStatus = await Permission.notification.request();

  // 권한 상태를 확인하여 추가 작업을 수행할 수 있습니다.
  if (locationStatus.isGranted) {
    print("위치 권한 허용됨");
  } else {
    print("위치 권한 거부됨");
  }

  if (notificationStatus.isGranted) {
    print("알림 권한 허용됨");
  } else {
    print("알림 권한 거부됨");
  }
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
    // 화면 높이를 가져옴 ( 핸드폰 규격에 맞게 %로 설정 가능하여 반응형 Ui 적용이 가능해졌다. )
    double screenHeight = MediaQuery.of(context).size.height;
    // 화면 높이에 따라 BottomNavigationBar의 높이 설정
    double bottomBarHeight = screenHeight * 0.1; // 예시: 화면 높이의 8%로 설정

    return Scaffold(
      backgroundColor: primary_color, // Scaffold 배경색 설정
      body: _widgetOptions(context).elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        height: bottomBarHeight, // 반응형 높이 설정
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
              icon: Icon(Icons.home_outlined, size: 22), // 아이콘 크기 조절
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_outlined, size: 22), // 아이콘 크기 조절
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22), // 아이콘 크기 조절
              label: '마이페이지',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: primary_color,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // 네비게이션 바의 배경색 설정
          selectedLabelStyle: TextStyle(fontSize: 12), // 선택된 아이템의 텍스트 크기 조절
          unselectedLabelStyle: TextStyle(fontSize: 10), // 선택되지 않은 아이템의 텍스트 크기 조절
        ),
      ),
    );
  }
}