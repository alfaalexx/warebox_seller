import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String userUid;
  final String reservationId;
  final double warehousePrice;
  final String paymentMethod;
  final String status;

  Payment({
    required this.userUid,
    required this.reservationId,
    required this.warehousePrice,
    required this.paymentMethod,
    required this.status,
  });

  // Tambahkan konstruktor dari dokumen snapshot
  factory Payment.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Payment(
      userUid: data['userUid'],
      reservationId: data['reservationId'],
      warehousePrice: data['warehousePrice'],
      paymentMethod: data['paymentMethod'],
      status: data['status'],
    );
  }
}
