import 'dart:io'; // 파일 작업을 위한 dart:io 패키지 import
import 'dart:convert'; // JSON 변환을 위한 dart:convert 패키지 import
import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위해 Provider 패키지를 import
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 image_picker 패키지 import
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위한 permission_handler 패키지 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 http 패키지 import
import 'package:path/path.dart' as path; // 파일 경로 작업을 위한 path 패키지 import
import 'package:mime/mime.dart'; // MIME 타입 처리를 위한 mime 패키지 import
import '../main.dart'; // 메인 화면을 import
import '../models/item.dart'; // 아이템 모델을 import
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
    var status = await Permission.photos.status; // 사진 권한 상태 확인
    if (!status.isGranted) {
      status = await Permission.photos.request(); // 권한 요청
    }

    try {
      final picker = ImagePicker(); // ImagePicker 인스턴스 생성
      final pickedImage = await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path); // 선택된 이미지를 _selectedImage에 저장
        });
      } else {
        print('No image selected'); // 선택된 이미지가 없을 경우 출력
      }
    } catch (e) {
      print('Error picking image: $e'); // 에러 발생 시 출력
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

  //   final newItem = Item(
  //     id: DateTime.now().toString(),
  //     title: title,
  //     description: description,
  //     price: price,
  //     endDateTime: _endDateTime!,
  //     bidUnit: bidUnit,
  //
  //   );
  //
  //   try {
  //     await itemProvider.addItem(newItem); // 아이템 추가 요청
  //     Provider.of<ItemProvider>(context, listen: false).fetchItems(); // 아이템 목록 갱신
  //     Navigator.of(context).push(
  //       MaterialPageRoute(builder: (context) => MainScreen()),
  //     );
  //   } catch (error) {
  //     print('Failed to add item: $error');
  //   }
  // }

    final url = Uri.parse('http://localhost:8080/api/items'); // 서버 URL

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
        var mimeType = lookupMimeType(_selectedImage!.path) ?? 'application/octet-stream';
        var file = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );
        request.files.add(file);
      }

      var response = await request.send(); // 요청 전송

      if (response.statusCode == 201) {
        print('Item added successfully');
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
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상 설정
        ),
        elevation: 0,
        backgroundColor: Colors.white, // 앱바 배경색 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // 패딩 설정
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 10),
              // _selectedImage != null
              //     ? Image.file(
              //   _selectedImage!,
              //   width: 100,
              //   height: 100,
              //   fit: BoxFit.cover,
              // )
              //     : const Text('사진를 올려주세요!'),
              // TextButton(
              //   onPressed: _pickImage,
              //   child: const Text('사진 선택'),
              // ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController, // 제목 입력 컨트롤러
                decoration: const InputDecoration(labelText: '제목'), // 제목 입력 필드의 힌트 텍스트
              ),
              TextField(
                controller: _priceController, // 시초가 입력 컨트롤러
                decoration: const InputDecoration(labelText: '시초가'), // 시초가 입력 필드의 힌트 텍스트
                keyboardType: TextInputType.number, // 숫자 키보드 사용
              ),
              const SizedBox(height: 10), // 간격 추가
              ListTile(
                title: Text(
                  _endDateTime == null
                      ? '경매 종료 시간을 선택해주세요'
                      : '종료 시간: ${_endDateTime!.toLocal()}'.split('.')[0], // 종료 시간을 텍스트로 표시
                ),
                trailing: const Icon(Icons.calendar_today), // 캘린더 아이콘
                onTap: _pickEndDateTime, // 시간 선택 메서드 호출
              ),
              TextField(
                controller: _descriptionController, // 설명 입력 컨트롤러
                decoration: const InputDecoration(labelText: '자세한 설명'), // 설명 입력 필드의 힌트 텍스트
              ),
              TextField(
                controller: _bidUnitController, // 입찰 단위 입력 컨트롤러
                decoration: const InputDecoration(labelText: '입찰 단위'), // 입찰 단위 입력 필드의 힌트 텍스트
                keyboardType: TextInputType.number, // 숫자 키보드 사용
              ),
              const SizedBox(height: 10), // 간격 추가
              ElevatedButton(
                onPressed: _submitData, // 데이터 제출 메서드 호출
                child: const Text('상품 등록'), // 버튼 텍스트
              ),
            ],
          ),
        ),
      ),
    );
  }
}