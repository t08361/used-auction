import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../screens/item_detail_screen.dart';

class ItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    return ListView.builder(
      itemCount: itemProvider.items.length,
      itemBuilder: (context, index) {
        final item = itemProvider.items[index];
        return ListTile(
          leading: Image.file(
            item.imageFile,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
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
          onLongPress: () => itemProvider.removeItem(item.id),
        );
      },
    );
  }
}
