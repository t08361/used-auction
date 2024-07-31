import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import '../models/item.dart';
import '../providers/item_provider.dart';
import 'package:provider/provider.dart';  // 상태 관리를 위한 Provider 패키지

// 아이템을 편집하는 화면을 제공하는 StatefulWidget
class ItemEditScreen extends StatefulWidget {
  final Item item; // 편집할 아이템을 전달받기 위한 필드

  const ItemEditScreen({super.key, required this.item});

  @override
  _ItemEditScreenState createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하기 위한 GlobalKey
  late String _title; // 아이템의 제목을 저장할 변수
  late String _description; // 아이템의 설명을 저장할 변수

  @override
  void initState() {
    super.initState();
    _title = widget.item.title; // 초기값으로 전달받은 아이템의 제목 설정
    _description = widget.item.description; // 초기값으로 전달받은 아이템의 설명 설정
  }

  // 폼 데이터를 제출하는 함수
  void _submitForm() async {
    // 폼이 유효한지 검사
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // 폼의 상태를 저장

      try {
        // ItemProvider를 통해 아이템 수정 요청
        await Provider.of<ItemProvider>(context, listen: false)
            .modifyItem(widget.item.id, _title, _description);

        // 성공적으로 수정되었음을 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
        Navigator.of(context).pop(); // 수정 후 이전 화면으로 돌아감
      } catch (error) {
        // 수정에 실패했을 경우 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _title, // 초기값으로 현재 아이템의 제목 설정
                decoration: const InputDecoration(labelText: 'Title'), // 필드에 라벨 설정
                validator: (value) {
                  // 유효설 검사(제목이 비어있으면 오류 메시지 반환)
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!; // 저장 시 _title 변수에 값 저장
                },
              ),
              TextFormField(
                initialValue: _description, // 초기값으로 현재 아이템의 설명 설정
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  // 유효성 검사(설명이 비어있으면 오류 메시지 반환)
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!; // 저장 시 _description 변수에 값 저장
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm, // 버튼을 누르면 폼 제출
                child: const Text('Save'), // 버튼의 텍스트 설정
              ),
            ],
          ),
        ),
      ),
    );
  }
}
