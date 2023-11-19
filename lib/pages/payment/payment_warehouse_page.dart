import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage

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
  bool isUploading = false;

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
      DocumentSnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationID)
          .get();

      if (reservationSnapshot.exists) {
        setState(() {
          reservation = Reservation.fromSnapshot(reservationSnapshot);
        });
      }

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

  Future<void> uploadPaymentReceiptImage(File imageFile) async {
    try {
      setState(() {
        isUploading = true;
      });

      String storagePath =
          'payment_receipts/${getCurrentUserUid()}/${widget.reservationID}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference storageReference =
          FirebaseStorage.instance.ref().child(storagePath);

      await storageReference.putFile(imageFile);

      String downloadUrl = await storageReference.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('payments')
          .doc(payment?.id)
          .update({
        'paymentReceiptImageUrl': downloadUrl,
        'status': 'Waiting for payment verification from WareBox Admin',
        'paidDate': Timestamp.now()
      });

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservation?.id)
          .update({
        'paymentStatus': 'Waiting for payment verification from WareBox Admin',
      });

      setState(() {
        payment?.paymentReceiptImageUrl = downloadUrl;
        isUploading = false;
      });

      // Reload the data to get the latest changes
      await loadReservationAndPaymentData();
    } catch (e) {
      print('Error uploading payment receipt image: $e');
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> pickImageAndUpload() async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        File imageFile = File(pickedImage.path);
        await uploadPaymentReceiptImage(imageFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        isUploading = false;
      });
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
          child: SingleChildScrollView(
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
                  if (payment?.paymentReceiptImageUrl != null)
                    CachedNetworkImage(
                      imageUrl: payment!.paymentReceiptImageUrl!,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ElevatedButton(
                    onPressed:
                        (isUploading || payment?.paymentReceiptImageUrl != null)
                            ? null
                            : pickImageAndUpload,
                    child: Text('Upload Payment Receipt'),
                  ),
                  if (isUploading) CircularProgressIndicator(),
                ] else
                  Text('Payment data not available'),
              ],
            ),
          ),
        ),
      );
    } else
      return Scaffold(
        body: Center(
          child: Text('Unauthorized Access'),
        ),
      );
  }
}
