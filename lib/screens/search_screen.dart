import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리 import
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지 import
import '../models/item.dart'; // Item 모델 import
import '../providers/item_provider.dart'; // ItemProvider import
import '../screens/item_detail_screen.dart'; // ItemDetailScreen import

// buildActions 매서드
// buildLeading 매서드
// 🔴 텍스트 입력만 하여도 상품을 제안해주는 메서드
// 🟠 텍스트 입력 후 검색하면 해당 상품을 보여주는 메서드

// SearchDelegate를 확장하여 검색 기능 구현
class ItemSearch extends SearchDelegate<Item?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear), // 검색창을 지우는 아이콘 버튼
        onPressed: () {
          query = ''; // 검색창 비우기
          showSuggestions(context); // 제안 목록 표시
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow, // 애니메이션 아이콘
        progress: transitionAnimation, // 애니메이션 진행 상태
      ),
      onPressed: () {
        close(context, null); // 검색 종료
      },
    );
  }

  //🔴 텍스트 입력만 하여도 상품을 제안해주는 메서드
  @override
  Widget buildSuggestions(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final suggestions = query.isEmpty
        ? [] // 검색어가 없으면 빈 리스트 반환
        : itemProvider.items.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Text('원하는 상품을 검색해주세요.'), // 검색 결과가 없을 때 메시지
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: suggestion.itemImages.isNotEmpty
              ? Image.network(
            suggestion.itemImages[0], // 첫 번째 이미지 URL 사용
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
              : Icon(Icons.image, size: 50), // 이미지가 없을 경우 아이콘 사용
          title: Text(suggestion.title),
          onTap: () {
            query = suggestion.title;
            showResults(context); // 검색 결과 표시
          },
        );
      },
    );
  }

  //🟠 텍스트 입력 후 검색하면 해당 상품을 보여주는 메서드
  @override
  Widget buildResults(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final results = itemProvider.items.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
          trailing: Text('\$${item.price.toString()}'), // 가격 표시
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item), // 아이템 상세 화면으로 이동
              ),
            );
          },
        );
      },
    );
  }
}