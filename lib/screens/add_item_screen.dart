import 'dart:io';
import 'package:flutter/material.dart'; // Flutter의 Meterial 디자인 라이브러리
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 image_picker 패키지
import 'package:firebase_storage/firebase_storage.dart'; // Firebase 스토리지와 상호작용하기 위한 패키지
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지
import 'package:image/image.dart' as img; // image 패키지의 네임스페이스 지정
import 'package:testhandproduct/screens/login_screen.dart'; // 로그인 화면
import 'package:geolocator/geolocator.dart'; // 현재 위치 정보를 얻기 위한 geolocator 패키지
import 'package:geocoding/geocoding.dart'; // 좌표를 주소로 변환하기 위한 geocoding 패키지
import '../main.dart'; // 메인 화면
import '../providers/constants.dart';
import '../providers/item_provider.dart'; // 아이템 상태 관리를 위한 provider
import '../providers/user_provider.dart'; // 사용자 상태 관리를 위한 provider

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add-item'; // 이 화면의 라우트 이름 정의

  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // 텍스트 입력 필드를 제어하기 위한 컨트롤러 정의
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bidUnitController = TextEditingController();
  final _regionController = TextEditingController();

  // 사용자가 선택한 이미지 파일들을 저장할 리스트
  List<File> _selectedImages = [];
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateBidUnitDefault); // 시초가에 따른 입찰 단위 업데이트 리스너 추가
    _setDefaultLocation(); // 사용자의 위치 설정 함수 호출
  }

  // 시초가 입력에 따라 입찰 단위 자동 설정에 대한 계산 함수
  void _updateBidUnitDefault() {
    final price = int.tryParse(_priceController.text) ?? 0; // 시초가를 숫자로 변환
    final defaultBidUnit = ((price * 0.01).round() / 10).ceil() * 10; // 십의 자리 반올림
    _bidUnitController.text = defaultBidUnit > 0 ? defaultBidUnit.toString() : ''; // 계산된 값을 텍스트 필드에 설정
  }

  // 사용자의 현재 위치를 가져와서 지역 필드에 설정하는 함수
  Future<void> _setDefaultLocation() async {
    try {
      // 사용자의 현재 위치를 얻음
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // 위치를 주소로 변환
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      if (mounted) { // 위젯이 여전히 활성화되어 있는지 확인
        setState(() {
           // 변환된 주소를 지역 필드에 설정
          _regionController.text = '${place.locality}. ${place.subLocality}. ${place.name} ';
        });
      }
    } catch (e) {
      print('Failed to get location: $e'); // 위치 가져오기 실패 시 오류 출력
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_updateBidUnitDefault); // 리스너 제거
    _priceController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 이미지 압축 및 변환 함수
  Future<File> _optimizeImage(File imageFile) async {
    // 이미지를 읽어들임
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) {
      throw Exception("이미지 디코딩에 실패했습니다.");
    }

    // 이미지 크기를 조정할 수 있습니다 (예: 가로 800px, 세로는 비율에 맞춰 자동 조정)
    final resizedImage = img.copyResize(image, width: 800);

    // 이미지를 jpg 포맷으로 변환하고 압축 (품질을 85%로 설정)
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    // 임시 파일로 저장
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedImageBytes);

    return tempFile;
  }


  // 이미지 선택을 처리하는 함수
  Future<void> _pickImages() async {
    final picker = ImagePicker(); // ImagePicker 인스턴스 생성
    final pickedFiles = await picker.pickMultiImage(); // 여러 이미지를 선택

    // 선택된 이미지를 최적화
    final optimizedImages = await Future.wait(
      pickedFiles.map((file) async => await _optimizeImage(File(file.path))),
    );

    setState(() {
      _selectedImages = optimizedImages; // 최적화된 이미지 파일을 리스트에 추가
      });
    }
  }



  // 경매 종료일을 등록 시간 기준 1일 후로 설정하는 버튼 기능
  void _setEndDateTimeOneDayLater() {
    setState(() {
      _endDateTime = DateTime.now().add(const Duration(days: 1)); // 현재 시간에서 1일 더한 시간 설정
    });
  }

  // 선택된 이미지를 Firebase에 업로드하고 URL을 반환하는 함수
  Future<List<String?>> _uploadImagesToFirebase(List<File> images) async {
    List<String?> imageUrls = [];

    for (var image in images) {
      try {
        // Firebase 스토리지 참조를 얻어 이미지 업로드
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child(
            'item_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');
        await imageRef.putFile(image);
        final imageUrl = await imageRef.getDownloadURL(); // 업로드된 이미지의 URL을 가져옴
        imageUrls.add(imageUrl); // URL을 리스트에 추가
      } catch (e) {
        print('이미지 업로드 실패: $e'); // 업로드 실패 시 오류 출력
        imageUrls.add(null); // 실패한 경우 null 추가
      }
    }

    return imageUrls; // 업로드된 이미지 URL 리스트 반환
  }

  // 경매 종료일과 시간을 선택하는 함수
  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return; // 날짜를 선택하지 않은 경우 함수 종료

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return; // 시간을 선택하지 않은 경우 함수 종료

    setState(() {
      // 선택된 날짜와 시간을 결합하여 _endDataTime 변수에 설정
      _endDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  bool _isLoading = false; // 로딩 상태를 관리하는 변수

  // 데이터를 서버에 제출하는 함수
  Future<void> _submitData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false); // UserProvider 인스턴스 가져오기
    final itemProvider = Provider.of<ItemProvider>(context, listen: false); // ItemProvider 인스턴스 가져오기

    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final bidUnit = int.tryParse(_bidUnitController.text);
    final region = _regionController.text;

    // 입력값 유효성 검사
    if (title.isEmpty ||
        description.isEmpty ||
        price == null ||
        price <= 0 ||
        _endDateTime == null ||
        bidUnit == null ||
        bidUnit <= 0 ||
        region.isEmpty) {
      // 오류가 있는 필드 출력
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected images: $_selectedImages");
      print("End DateTime: $_endDateTime");
      print("Bid Unit: $bidUnit");
      print("Region is empty: ${region.isEmpty}");
      return; // 유효하지 않은 입력이 있으면 함수 종료
    }

    setState(() {
      _isLoading = true; // 로딩 상태로 변경
    });

    // 이미지를 Firebase에 업로드
    List<String?> imageUrls = await _uploadImagesToFirebase(_selectedImages);

    // 업로드에 실패한 이미지가 있을 경우 처리
    if (imageUrls.contains(null)) {
      print('Some images failed to upload');
      setState(() {
        _isLoading = false; // 로딩 상태 해제
      });
      return; // 업로드 실패 시 함수 종료
    }

    final url = Uri.parse('$baseUrl/items');

    try {
      // 서버에 데이터를 전송하기 위한 MultipartRequest 생성
      var request = http.MultipartRequest('POST', url);

      // 요청 필드에 데이터를 추가
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['endDateTime'] = _endDateTime!.toIso8601String();
      request.fields['bidUnit'] = bidUnit.toString();
      request.fields['userId'] = userProvider.id;
      request.fields['nickname'] = userProvider.nickname;
      request.fields['region'] = region; // 지역 필드 추가

      // 업로드된 이미지 URL을 요청 파일로 추가
      for (var imageUrl in imageUrls) {
        if (imageUrl != null) {
          request.files.add(http.MultipartFile.fromString('itemImages', imageUrl));
        }
      }

      if (userProvider.isLoggedIn) {
        var response = await request.send(); // 요청 전송

        if (response.statusCode == 201) { // 서버가 성공적으로 응답한 경우
          print('상품 등록 성공');
          itemProvider.fetchItems(); // 아이템 목록 갱신
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()), // 메인 화면으로 이동
          );
        } else {
          print('Failed to add item');
          print(await response.stream.bytesToString()); // 서버 응답 본문 출력
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
        );
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 상태 해제
      });
    }
  }

//🟡메인 화면
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록', style: TextStyle(color: Colors.black)),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading // 로딩 중이면 로딩 인디케이터를 표시
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _pickImages, // 이미지 선택 함수 호출
                  child: _selectedImages.isNotEmpty
                      ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _selectedImages.map((image) {
                      return Image.file(
                        image,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  )
                      : Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: background_color,
                      border: Border.all(color: Colors.black45),
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
              const Text('제목',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('시초가',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: '시초가를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('경매 종료 시간',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(
                        _endDateTime == null
                            ? '경매 종료 시간을 선택해주세요'
                            : '종료 시간: ${_endDateTime!.toLocal()}'.split('.')[0],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickEndDateTime, // 경매 종료일 선택 함수 호출
                    ),
                  ),
                  TextButton(
                    onPressed: _setEndDateTimeOneDayLater, // 1일 후로 경매 종료일 설정
                    child: const Text('1일'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('자세한 설명',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: '상품에 대한 자세한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitData(), // 완료 버튼을 누르면 데이터 제출
              ),
              const SizedBox(height: 20),
              const Text('입찰 단위',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _bidUnitController,
                decoration: InputDecoration(
                  hintText: '입찰 단위를 입력하세요',
                  border: const OutlineInputBorder(),
                  labelText: '입찰 단위 (기본값: ${_priceController.text.isNotEmpty ? (int.parse(_priceController.text) * 0.01).round().toString() : '시초가를 입력하세요'})',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('지역',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _regionController,
                decoration: InputDecoration(
                  hintText: '지역을 입력하세요',
                  border: const OutlineInputBorder(),
                  labelText: _regionController.text.isNotEmpty ? _regionController.text : '현재 위치를 가져오는 중...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData, // 데이터 제출 함수 호출
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('상품 등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
