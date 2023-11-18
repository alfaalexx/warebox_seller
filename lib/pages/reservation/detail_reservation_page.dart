import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/payment/payment_warehouse_page.dart';

class DetailReservationPage extends StatelessWidget {
  final Reservation reservation;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  DetailReservationPage({Key? key, required this.reservation})
      : super(key: key);

  Future<void> handleCancelPayment(BuildContext context) async {
    final reservationRef = FirebaseFirestore.instance
        .collection('reservations')
        .doc(reservation.id);

    try {
      // Use a batch to delete both documents
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Verify the existence of the 'payments' document
      DocumentSnapshot reservationSnapshot = await reservationRef.get();

      if (reservationSnapshot.exists) {
        // If the reservation document exists, get the reservation data
        Reservation reservationData =
            Reservation.fromSnapshot(reservationSnapshot);

        // Check if the reservation has a payment ID
// Note: The error message suggests that reservationData.paymentId is never null
// so you can safely remove the null check.
// if (reservationData.paymentId != null) {
// If the reservation has a payment ID, delete the payment document
        DocumentReference paymentRef = FirebaseFirestore.instance
            .collection('payments')
            .doc(reservationData.paymentId);

        batch.delete(paymentRef);
// }
      }

      // Delete the reservation document
      batch.delete(reservationRef);

      // Commit the batch
      await batch.commit();

      // Menampilkan snackbar atau pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation deleted successfully!'),
        ),
      );

      // Navigasi atau tindakan lanjutan setelah penghapusan berhasil
      Navigator.pop(context);
    } catch (e) {
      // Menampilkan pesan atau log error
      print('Error cancelling payment: $e');
      // Handle errors, show an error message, etc.
    }
  }

  void handleContinuePayment(BuildContext context) {
    // Implement logic to navigate to payment page with reservationID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWarehousePage(
          reservationID: reservation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canModifyPayment =
        currentUser != null && currentUser!.uid == reservation.userUid;
    bool isPaymentUnpaid = reservation.paymentStatus == 'Unpaid';

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

            // Show buttons based on conditions
            if (canModifyPayment && isPaymentUnpaid) ...[
              ElevatedButton(
                onPressed: () => handleCancelPayment(context),
                child: Text('Cancel Payment'),
              ),
              ElevatedButton(
                onPressed: () => handleContinuePayment(context),
                child: Text('Continue Payment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
