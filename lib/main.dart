import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/chat_provider.dart';
import 'providers/constants.dart';
import 'providers/item_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/user_mypage.dart';


// 앱에서 사용할 provider 설정
// 사용자 권한 요청 함수
// 최상위 위젯인 MyApp
// 하단 앱바를 포함한 홈화면
// 하단 앱바 Ui



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 위젯 바인딩을 초기화
  await Firebase.initializeApp(); // Firebase를 초기화

  await requestPermissions(); // 앱 시작 시 권한 요청

  runApp(
    // 앱에서 사용할 provider 설정
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        // 아이템 관련 상태 관리
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // 사용자 관련 상태 관리
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        // 채팅 관련 상태 관리
      ],
      child: MyApp(), // 최상위 위젯인 MyApp 실행
    ),
  );
}

// 사용자 권한 요청 함수
Future<void> requestPermissions() async {
  // 위치 권한 요청
  PermissionStatus locationStatus =
      await Permission.locationWhenInUse.request();
  // 알림 권한 요청 (iOS의 경우)
  PermissionStatus notificationStatus = await Permission.notification.request();

  // 권한 상태 확인
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

// 최상위 위젯인 MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).loadUser(); // 사용자 정보 로드

    return MaterialApp(
      title: '중고 거래 앱', // 앱 제목
      theme: ThemeData(
        primarySwatch: Colors.red, // 기본 테마 색상
      ),
      home: MainScreen(), // 앱 시작 시 표시할 화면
      routes: {
        '/login': (context) => LoginScreen(), // 로그인 화면
        '/user': (context) => UserPage(), // 사용자 페이지
        '/home': (context) => HomeScreen(), // 홈 화면
        '/add-item': (context) => AddItemScreen(), // 아이템 추가 화면
      },
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

// 하단 앱바를 포함한 홈화면
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 선택된 하단 네비게이션 바 인덱스

  // 각 인덱스에 해당하는 위젯 리스트
  List<Widget> _widgetOptions(BuildContext context) {
    return <Widget>[
      HomeScreen(), // 홈 화면
      ChatListScreen(), // 채팅 목록 화면
      Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return userProvider.isLoggedIn
              ? UserPage()
              : LoginScreen(); // 로그인 여부에 따라 화면 변경
        },
      ),
    ];
  }

  // 하단 네비게이션 바 아이템 선택 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스로 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; // 화면 높이를 가져옴
    double bottomBarHeight = screenHeight * 0.1; // 하단 네비게이션 바의 높이 설정

    return Scaffold(
      backgroundColor: primary_color, // 앱의 기본 배경색
      body: _widgetOptions(context).elementAt(_selectedIndex), // 선택된 인덱스의 위젯 표시
      bottomNavigationBar: Container(
        height: bottomBarHeight, // 하단 네비게이션 바 높이 설정
        decoration: const BoxDecoration(
          color: Colors.white, // 하단 네비게이션 바 배경색 설정
          border: Border(
            top: BorderSide(
              color: Colors.grey, // 상단 경계선 색상
              width: 0.2, // 상단 경계선 너비
            ),
          ),
        ),

        // 하단 앱바 Ui
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22), // 홈 아이콘
              label: '홈', // 홈 라벨
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_outlined, size: 22),
              // 채팅 아이콘
              label: '채팅', // 채팅 라벨
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22), // 마이페이지 아이콘
              label: '마이페이지', // 마이페이지 라벨
            ),
          ],
          // 현재 선택된 인덱스
          currentIndex: _selectedIndex,
          // 선택된 아이템 색상
          selectedItemColor: primary_color,
          // 선택되지 않은 아이템 색상
          unselectedItemColor: Colors.grey,
          // 아이템 탭 시 호출되는 함수
          onTap: _onItemTapped,
          // 네비게이션 바 배경색
          backgroundColor: Colors.white,
          // 선택된 아이템의 텍스트 크기
          selectedLabelStyle: TextStyle(fontSize: 12),
          // 선택되지 않은 아이템의 텍스트 크기
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
