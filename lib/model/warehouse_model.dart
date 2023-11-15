import 'package:cloud_firestore/cloud_firestore.dart';

class Warehouse {
  final String id;
  final String itemName;
  final String itemNameLowercase;
  final String category;
  final String itemDescription;
  final String uid;
  final int itemLarge;
  final int quantity;
  final String serialNumber;
  final String location;
  final String warehouseStatus;
  final List<String> features;
  final String additionalNotes;
  final double pricePerDay;
  final double pricePerWeek;
  final double pricePerMonth;
  final double pricePerYear;
  final String? warehouseImageUrl;
  final List<String>? detailImageUrls;

  Warehouse({
    required this.id,
    this.itemName = '',
    this.itemNameLowercase = '',
    this.category = '',
    this.itemDescription = '',
    this.uid = '',
    this.itemLarge = 0,
    this.quantity = 0,
    this.serialNumber = '',
    this.location = '',
    this.warehouseStatus = 'available',
    required this.features,
    this.additionalNotes = '',
    this.pricePerDay = 0.0,
    this.pricePerWeek = 0.0,
    this.pricePerMonth = 0.0,
    this.pricePerYear = 0.0,
    this.warehouseImageUrl,
    this.detailImageUrls,
  });

  factory Warehouse.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Initialize with default values or the values from the document
    String itemName = data['itemName'] as String? ?? '';
    String itemNameLowercase = itemName.toLowerCase();
    String category = data['category'] as String? ?? '';
    String itemDescription = data['itemDescription'] as String? ?? '';
    String uid = data['uid'] as String? ?? '';
    int itemLarge = data['itemLarge'] as int? ?? 0;
    int quantity = data['quantity'] as int? ?? 0;
    String serialNumber = data['serialNumber'] as String? ?? '';
    String location = data['location'] as String? ?? '';
    String warehouseStatus = data['warehouseStatus'] as String? ?? 'available';
    List<String> features = (data['features'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    String additionalNotes = data['additionalNotes'] as String? ?? '';
    double pricePerDay = (data['pricePerDay'] as num?)?.toDouble() ?? 0.0;
    double pricePerWeek = (data['pricePerWeek'] as num?)?.toDouble() ?? 0.0;
    double pricePerMonth = (data['pricePerMonth'] as num?)?.toDouble() ?? 0.0;
    double pricePerYear = (data['pricePerYear'] as num?)?.toDouble() ?? 0.0;
    String? warehouseImageUrl = data['warehouseImageUrl'] as String?;
    List<String>? detailImageUrls = (data['detailImageUrls'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    return Warehouse(
      id: doc.id,
      itemName: itemName,
      itemNameLowercase: itemNameLowercase,
      category: category,
      itemDescription: itemDescription,
      uid: uid,
      itemLarge: itemLarge,
      quantity: quantity,
      serialNumber: serialNumber,
      location: location,
      warehouseStatus: warehouseStatus,
      features: features,
      additionalNotes: additionalNotes,
      pricePerDay: pricePerDay,
      pricePerWeek: pricePerWeek,
      pricePerMonth: pricePerMonth,
      pricePerYear: pricePerYear,
      warehouseImageUrl: warehouseImageUrl,
      detailImageUrls: detailImageUrls,
    );
  }
}
