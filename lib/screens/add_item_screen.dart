import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testhandproduct/main.dart';
import 'package:testhandproduct/screens/home_screen.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

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
  File? _selectedImage;
  DateTime? _endDateTime;

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
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

  void _submitData(BuildContext context) {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final bidUnit = int.tryParse(_bidUnitController.text);

    if (title.isEmpty || description.isEmpty || price == null || price <= 0 || _selectedImage == null || _endDateTime == null || bidUnit == null || bidUnit <= 0) {
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected image: $_selectedImage");
      print("End DateTime: $_endDateTime");
      print("Bid Unit: $bidUnit");
      return;
    }

    final newItem = Item(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      price: price,
      endDateTime: _endDateTime!,
      bidUnit: bidUnit,
      imageFile: _selectedImage!,
    );

    Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            '상품 등록',
            style: TextStyle(color: Colors.black)
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // 뒤로가기 버튼 색상을 검은색으로 설정
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : const Text('사진를 올려주세요!'),
              TextButton(
                onPressed: _pickImage,
                child: const Text('사진 선택'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '시초가'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  _endDateTime == null
                      ? '경매 종료 시간을 선택해주세요'
                      : '종료 시간: ${_endDateTime!.toLocal()}'.split('.')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndDateTime,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '자세한 설명'),
              ),
              TextField(
                controller: _bidUnitController,
                decoration: const InputDecoration(labelText: '입찰 단위'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _submitData(context),
                child: const Text('상품 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
