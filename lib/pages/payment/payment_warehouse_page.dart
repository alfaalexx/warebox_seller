import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentWarehousePage extends StatefulWidget {
  final String reservationID;
  const PaymentWarehousePage({Key? key, required this.reservationID})
      : super(key: key);

  @override
  State<PaymentWarehousePage> createState() => _PaymentWarehousePageState();
}

class _PaymentWarehousePageState extends State<PaymentWarehousePage> {
  Reservation? reservation;
  Payment? payment;

  @override
  void initState() {
    super.initState();
    loadReservationAndPaymentData();
  }

  String? getCurrentUserUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> loadReservationAndPaymentData() async {
    try {
      // Mengambil data reservation berdasarkan reservationID
      DocumentSnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationID)
          .get();

      if (reservationSnapshot.exists) {
        setState(() {
          reservation = Reservation.fromSnapshot(reservationSnapshot);
        });
      }

      // Mengambil data payment berdasarkan reservationID
      QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('reservationId', isEqualTo: widget.reservationID)
          .get();

      if (paymentSnapshot.docs.isNotEmpty) {
        setState(() {
          payment = Payment.fromSnapshot(paymentSnapshot.docs.first);
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && payment?.userUid == currentUser.uid) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Payment Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reservation Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reservation != null) ...[
                Text('Warehouse ID: ${reservation!.warehouseId}'),
                Text('Duration Type: ${reservation!.durationType}'),
                Text('User UID: ${reservation!.userUid}'),
                Text('Status: ${reservation!.status}'),
                Text('Is Paid: ${reservation!.isPaid}'),
                Text('Payment Status: ${reservation!.paymentStatus}'),
                SizedBox(height: 20),
              ] else
                Text('Reservation data not available'),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (payment != null) ...[
                Text('User UID: ${payment!.userUid}'),
                Text('Reservation ID: ${payment!.reservationId}'),
                Text('Warehouse Price: ${payment!.warehousePrice}'),
                Text('Payment Method: ${payment!.paymentMethod}'),
                Text('Status: ${payment!.status}'),
              ] else
                Text('Payment data not available'),
            ],
          ),
        ),
      );
    } else
      // Handle unauthorized access, for example, redirect to another page
      // You can replace the code below with your own logic
      return Scaffold(
        body: Center(
          child: Text('Unauthorized Access'),
        ),
      );
  }
}
