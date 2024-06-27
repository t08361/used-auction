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

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      // if (!status.isGranted) {
      //   print('Permission denied');
      //   return;
      // }
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

  void _submitData(BuildContext context) {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);

    if (title.isEmpty || description.isEmpty || price == null || price <= 0 || _selectedImage == null) {
      print("Invalid input:");
      print("Title is empty: ${title.isEmpty}");
      print("Description is empty: ${description.isEmpty}");
      print("Price: $price");
      print("Selected image: $_selectedImage");
      return;
    }

    final newItem = Item(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      price: price,
      imageFile: _selectedImage!,
    );

    Provider.of<ItemProvider>(context, listen: false).addItem(newItem);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '상품 등록',
            style: TextStyle(color: Colors.black)
        ),
        iconTheme: IconThemeData(
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: '자세한 설명'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: '시초가'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Text('사진를 올려주세요!'),
              TextButton(
                onPressed: _pickImage,
                child: Text('사진 선택'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _submitData(context),
                child: Text('상품 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
