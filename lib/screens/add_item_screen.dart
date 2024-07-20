import 'dart:io'; // 파일 작업을 위한 dart:io 패키지 import
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위해 Provider 패키지를 import
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 image_picker 패키지 import
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위한 permission_handler 패키지 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지 import
import '../main.dart'; // 메인 화면을 import
import '../providers/constants.dart';
import '../providers/item_provider.dart'; // ItemProvider를 import
import '../providers/user_provider.dart'; // 추가

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add-item'; // 라우트 이름 정의

  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState(); // 상태 관리 클래스를 생성
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleController = TextEditingController(); // 제목 입력 컨트롤러
  final _descriptionController = TextEditingController(); // 설명 입력 컨트롤러
  final _priceController = TextEditingController(); // 가격 입력 컨트롤러
  final _bidUnitController = TextEditingController(); // 입찰 단위 입력 컨트롤러
  File? _selectedImage; // 선택된 이미지 파일
  DateTime? _endDateTime; // 경매 종료 시간

  // 이미지를 선택하는 메서드
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 경매 종료 시간을 선택하는 메서드
  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _endDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute); // 선택된 날짜와 시간을 _endDateTime에 저장
    });
  }

  // 데이터를 제출하는 메서드
  Future<void> _submitData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    final title = _titleController.text; // 입력된 제목
    final description = _descriptionController.text; // 입력된 설명
    final price = int.tryParse(_priceController.text); // 입력된 가격을 정수로 변환
    final bidUnit = int.tryParse(_bidUnitController.text); // 입력된 입찰 단위를 정수로 변환

    if (title.isEmpty || description.isEmpty || price == null || price <= 0 || _endDateTime == null || bidUnit == null || bidUnit <= 0) {
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected image: $_selectedImage");
      print("End DateTime: $_endDateTime");
      print("Bid Unit: $bidUnit");
      return;
    }

    final url = Uri.parse('$baseUrl/items'); // 서버 URL

    try {
      var request = http.MultipartRequest('POST', url); // 멀티파트 요청 생성

      // 필드 추가
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['endDateTime'] = _endDateTime!.toIso8601String();
      request.fields['bidUnit'] = bidUnit.toString();
      request.fields['userId'] = userProvider.id; // 추가
      request.fields['nickname'] = userProvider.nickname; // 추가

      // 이미지 파일이 선택된 경우 파일 추가
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'item_image',
          _selectedImage!.path,
        ));
      }

      var response = await request.send(); // 요청 전송

      if (response.statusCode == 201) {
        print('상품 등록 성공');
        Provider.of<ItemProvider>(context, listen: false).fetchItems(); // 아이템 목록 갱신
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()), // MainScreen으로 이동
        );
      } else {
        print('Failed to add item'); // 아이템 추가 실패
      }
    } catch (error) {
      print('Error: $error'); // 에러 발생 시 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록', style: TextStyle(color: Colors.black)), // 앱바 제목
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상 설정
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 설정
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    width: 90, // 이미지 너비를 줄입니다.
                    height: 90, // 이미지 높이를 줄여 정사각형으로 만듭니다.
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 90, // 컨테이너 너비를 줄입니다.
                    height: 90, // 컨테이너 높이를 줄여 정사각형으로 만듭니다.
                    decoration: BoxDecoration(
                      color: background_color,
                      border: Border.all(color: Colors.black45), // 검은색 테두리 추가
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black54,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('제목', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _titleController, // 제목 입력 컨트롤러
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요', // 힌트 텍스트 추가
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('시초가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _priceController, // 시초가 입력 컨트롤러
                decoration: const InputDecoration(
                  hintText: '시초가를 입력하세요', // 힌트 텍스트 추가
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // 숫자 키보드 사용
              ),
              const SizedBox(height: 20), // 간격 추가
              const Text('경매 종료 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              ListTile(
                title: Text(
                  _endDateTime == null
                      ? '경매 종료 시간을 선택해주세요'
                      : '종료 시간: ${_endDateTime!.toLocal()}'.split('.')[0], // 종료 시간을 텍스트로 표시
                ),
                trailing: const Icon(Icons.calendar_today), // 캘린더 아이콘
                onTap: _pickEndDateTime, // 시간 선택 메서드 호출
              ),
              const SizedBox(height: 20), // 간격 추가
              const Text('자세한 설명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _descriptionController, // 설명 입력 컨트롤러
                decoration: const InputDecoration(
                  hintText: '상품에 대한 자세한 설명을 입력하세요', // 힌트 텍스트 추가
                  border: OutlineInputBorder(),
                ),
                maxLines: 5, // 설명 입력 필드의 최대 라인 수 설정
                textInputAction: TextInputAction.done, // 완료 액션 설정
                onSubmitted: (_) => _submitData(), // 완료 시 데이터 제출
              ),
              const SizedBox(height: 20), // 간격 추가
              const Text('입찰 단위', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _bidUnitController, // 입찰 단위 입력 컨트롤러
                decoration: const InputDecoration(
                  hintText: '입찰 단위를 입력하세요', // 힌트 텍스트 추가
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // 숫자 키보드 사용
              ),
              const SizedBox(height: 20), // 간격 추가
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData, // 데이터 제출 메서드 호출
                  child: const Text('상품 등록'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 각진 사각형으로 설정
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
