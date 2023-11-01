import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  CategoryModel.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        name = snapshot['name'],
        imageUrl = snapshot['imageUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
      };
}
