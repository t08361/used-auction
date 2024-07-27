import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:testhandproduct/screens/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../main.dart';
import '../providers/constants.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';

class AddItemScreen extends StatefulWidget {
  static const routeName = '/add-item';

  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _bidUnitController = TextEditingController();
  final _regionController = TextEditingController();

  List<File> _selectedImages = [];
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateBidUnitDefault);
    _setDefaultLocation(); // 사용자의 위치 설정 함수 호출
  }

  // 시초가에 입력에 따라 입찰 단위 자동 설정에 대한 계산 함수
  void _updateBidUnitDefault() {
    final price = int.tryParse(_priceController.text) ?? 0;
    final defaultBidUnit = ((price * 0.01).round() / 10).ceil() * 10; // 십의 자리 반올림
    _bidUnitController.text = defaultBidUnit > 0 ? defaultBidUnit.toString() : '';
  }

  // 사용자의 현재 위치를 가져와서 지역 필드에 설정하는 함수
  Future<void> _setDefaultLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      if (mounted) { // Ensure the widget is still mounted
        setState(() {
          _regionController.text = '${place.name}, ${place.street}, ${place.subLocality}, ${place.locality}, '
              '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
        });
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }


  @override
  void dispose() {
    _priceController.removeListener(_updateBidUnitDefault);
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }
  //경매 종료일을 등록 시간 기준 1일 후로 설정하는 버튼 기능
  void _setEndDateTimeOneDayLater() {
    setState(() {
      _endDateTime = DateTime.now().add(Duration(days: 1));
    });
  }

  Future<List<String?>> _uploadImagesToFirebase(List<File> images) async {
    List<String?> imageUrls = [];

    for (var image in images) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child(
            'item_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');
        await imageRef.putFile(image);
        final imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('이미지 업로드 실패: $e');
        imageUrls.add(null);
      }
    }

    return imageUrls;
  }

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
      _endDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  bool _isLoading = false; // 로딩 상태를 관리하는 변수

  Future<void> _submitData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final bidUnit = int.tryParse(_bidUnitController.text);
    final region = _regionController.text;

    if (title.isEmpty ||
        description.isEmpty ||
        price == null ||
        price <= 0 ||
        _endDateTime == null ||
        bidUnit == null ||
        bidUnit <= 0 ||
        region.isEmpty) {
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected images: $_selectedImages");
      print("End DateTime: $_endDateTime");
      print("Bid Unit: $bidUnit");
      print("Region is empty: ${region.isEmpty}");
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 상태로 변경
    });

    List<String?> imageUrls = await _uploadImagesToFirebase(_selectedImages);

    // 업로드에 실패한 이미지가 있을 경우 처리
    if (imageUrls.contains(null)) {
      print('Some images failed to upload');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/items');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['endDateTime'] = _endDateTime!.toIso8601String();
      request.fields['bidUnit'] = bidUnit.toString();
      request.fields['userId'] = userProvider.id;
      request.fields['nickname'] = userProvider.nickname;
      request.fields['region'] = region; // 지역 필드 추가

      for (var imageUrl in imageUrls) {
        if (imageUrl != null) {
          request.files.add(http.MultipartFile.fromString('itemImages', imageUrl));
        }
      }

      if (userProvider.isLoggedIn) {
        var response = await request.send();

        if (response.statusCode == 201) {
          print('상품 등록 성공');
          itemProvider.fetchItems(); // 아이템 목록 갱신
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          print('Failed to add item');
          print(await response.stream.bytesToString()); // 에러 메시지 확인
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
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
          ? Center(child: CircularProgressIndicator())
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
                  onTap: _pickImages,
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
                      onTap: _pickEndDateTime,
                    ),
                  ),
                  TextButton(
                    onPressed: _setEndDateTimeOneDayLater,
                    child: Text('1일'),
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
                onSubmitted: (_) => _submitData(),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                  labelText: _regionController.text.isNotEmpty ? _regionController.text : '현재 위치를 가져오는 중...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: const Text('상품 등록'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
