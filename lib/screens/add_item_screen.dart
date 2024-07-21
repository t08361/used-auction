import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:testhandproduct/screens/sales_history_screen.dart';
import '../main.dart';
import '../providers/constants.dart';
import '../providers/item_provider.dart';
import '../providers/user_provider.dart';
import '../models/item.dart'; // 추가
import 'sales_history_screen.dart';

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
  File? _selectedImage;
  DateTime? _endDateTime;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
      _endDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final bidUnit = int.tryParse(_bidUnitController.text);
    final region = _regionController.text;

    if (title.isEmpty || description.isEmpty || price == null || price <= 0 || _endDateTime == null || bidUnit == null || bidUnit <= 0 || region.isEmpty) {
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected image: $_selectedImage");
      print("End DateTime: $_endDateTime");
      print("Bid Unit: $bidUnit");
      print("Region is empty: ${region.isEmpty}");
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
      request.fields['userId'] = userProvider.id;
      request.fields['nickname'] = userProvider.nickname;
      request.fields['region'] = region;

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
        await itemProvider.fetchItems(); // 아이템 목록 갱신
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SaleHistoryPage()), // SaleHistoryPage로 이동
        );
      } else {
        print('Failed to add item');
      }
    } catch (error) {
      print('Error: $error');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
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
              const Text('제목', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('시초가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              const Text('경매 종료 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              ListTile(
                title: Text(
                  _endDateTime == null
                      ? '경매 종료 시간을 선택해주세요'
                      : '종료 시간: ${_endDateTime!.toLocal()}'.split('.')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndDateTime,
              ),
              const SizedBox(height: 20),
              const Text('자세한 설명', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              const Text('입찰 단위', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _bidUnitController,
                decoration: const InputDecoration(
                  hintText: '입찰 단위를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('지역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: _regionController,
                decoration: const InputDecoration(
                  hintText: '지역을 입력하세요',
                  border: OutlineInputBorder(),
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
