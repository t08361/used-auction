import 'dart:io';

class Item {
  final String id;
  final String title;
  final String description;
  final double price;
  final File imageFile;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageFile,
  });
}
