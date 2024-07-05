import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../screens/item_detail_screen.dart';

class ItemSearch extends SearchDelegate<Item?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null); // Null을 허용하도록 수정
      },
    );
  }

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
          // leading: Image.file(
          //   item.imageFile,
          //   width: 100,
          //   height: 100,
          //   fit: BoxFit.cover,
          // ),
          title: Text(item.title),
          subtitle: Text(item.description),
          trailing: Text('\$${item.price.toString()}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final suggestions = query.isEmpty
        ? []
        : itemProvider.items.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Image.file(
            suggestion.imageFile,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(suggestion.title),
          onTap: () {
            query = suggestion.title;
            showResults(context);
          },
        );
      },
    );
  }
}