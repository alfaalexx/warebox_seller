import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String warehouseId;
  final String durationType;
  final String userUid;
  final String status;
  final bool isPaid;
  final String paymentStatus;

  Reservation({
    required this.warehouseId,
    required this.durationType,
    required this.userUid,
    required this.status,
    required this.isPaid,
    required this.paymentStatus,
  });

  // Tambahkan konstruktor dari dokumen snapshot
  factory Reservation.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Reservation(
      warehouseId: data['warehouseId'],
      durationType: data['durationType'],
      userUid: data['userUid'],
      status: data['status'],
      isPaid: data['isPaid'],
      paymentStatus: data['paymentStatus'],
    );
  }
}
