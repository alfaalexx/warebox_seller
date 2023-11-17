import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailReservationPage extends StatelessWidget {
  final Reservation reservation;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  DetailReservationPage({Key? key, required this.reservation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the current user's UID matches the UID in the reservation
    if (currentUser != null && currentUser!.uid == reservation.userUid) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Reservation Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warehouse ID: ${reservation.warehouseId}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Duration Type: ${reservation.durationType}'),
              Text('User UID: ${reservation.userUid}'),
              Text('Status: ${reservation.status}'),
              Text('Is Paid: ${reservation.isPaid}'),
              Text('Payment Status: ${reservation.paymentStatus}'),
              // Add more fields as needed
            ],
          ),
        ),
      );
    } else {
      // Display a message or navigate to another page if the user doesn't have access
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
        ),
        body: Center(
          child: Text('You do not have access to view this reservation.'),
        ),
      );
    }
  }
}
