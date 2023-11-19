import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String warehouseId;
  final String durationType;
  final String userUid;
  final String status;
  final String paymentStatus;
  final String paymentId;

  Reservation({
    required this.id,
    required this.warehouseId,
    required this.durationType,
    required this.userUid,
    required this.status,
    required this.paymentStatus,
    required this.paymentId,
  });

  // Tambahkan konstruktor dari dokumen snapshot
  factory Reservation.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Reservation(
      id: snapshot.id,
      warehouseId: data['warehouseId'],
      durationType: data['durationType'],
      userUid: data['userUid'],
      status: data['status'],
      paymentStatus: data['paymentStatus'],
      paymentId: data['paymentId'],
    );
  }
}
