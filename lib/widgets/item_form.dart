import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';

class AddItemScreen extends StatefulWidget {
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
    // 권한 요청
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        return; // 권한이 거부된 경우
      }
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
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

  void _submitData(BuildContext context) {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final bidUnit = int.tryParse(_bidUnitController.text);

    if (title.isEmpty || description.isEmpty || price == null || price <= 0 || _selectedImage == null || _endDateTime == null || bidUnit == null || bidUnit <= 0) {
      return;
    }

    final newItem = Item(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      price: price,
      endDateTime: _endDateTime!,
      bidUnit: bidUnit!,
      imageFile: _selectedImage!,
    );

    Provider.of<ItemProvider>(context, listen: false).addItem(newItem);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 추가'),
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
                controller: _bidUnitController,
                decoration: InputDecoration(labelText: '입찰 단위'),
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
                  : Text('이미지가 선택되지 않았습니다'),
              TextButton(
                onPressed: _pickImage,
                child: Text('이미지 선택'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _submitData(context),
                child: Text('아이템 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
