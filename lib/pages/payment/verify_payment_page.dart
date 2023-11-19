import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
// Import model pembayaran

class VerifyPaymentPage extends StatefulWidget {
  @override
  _VerifyPaymentPageState createState() => _VerifyPaymentPageState();
}

class _VerifyPaymentPageState extends State<VerifyPaymentPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Payments'),
      ),
      body: currentUser != null
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('payments')
                  .where('isVerifyPayment', isEqualTo: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<Payment> payments = snapshot.data!.docs
                      .map((DocumentSnapshot document) =>
                          Payment.fromSnapshot(document))
                      .toList();
                  if (payments.isNotEmpty) {
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        Payment payment = payments[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                'Reservation ID: ${payment.reservationId}'),
                            subtitle: Text(
                                'Warehouse Price: ${payment.warehousePrice}'),
                            onTap: () {
                              // Navigate to payment detail page with payment data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPaymentPage(
                                    context: context,
                                    payment: payment,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('Payments not found'),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          : Center(
              child: Text('User not logged in'),
            ),
    );
  }
}

class DetailPaymentPage extends StatelessWidget {
  final BuildContext context;
  final Payment payment;

  const DetailPaymentPage(
      {Key? key, required this.context, required this.payment})
      : super(key: key);

  void _rejectVerification() async {
    // Show a dialog to input the reason for rejection
    String? rejectionReason = await _showRejectionDialog();

    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      try {
        // Update data reservation
        await FirebaseFirestore.instance
            .collection('reservations')
            .doc(payment.reservationId)
            .update({
          'paymentStatus': 'Payment Denied',
        });

        // Update data payment
        await FirebaseFirestore.instance
            .collection('payments')
            .doc(payment.id)
            .update({
          'isVerifyPayment': false,
          'status': 'Payment Denied',
          'reasonRejection': rejectionReason,
        });

        // Show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification rejected!'),
          ),
        );

        // Close the detail payment page
        Navigator.pop(context, true);
      } catch (e) {
        // Handle errors
        print('Error during rejection: $e');
      }
    }
  }

  Future<String?> _showRejectionDialog() async {
    String? rejectionReason = '';

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reason for Rejection'),
          content: TextField(
            onChanged: (value) {
              rejectionReason = value;
            },
            decoration: InputDecoration(labelText: 'Enter reason...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, rejectionReason);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _approveVerification() async {
    // Tambahkan logika persetujuan verifikasi di sini
    try {
      // Update data reservation
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(payment.reservationId)
          .update({
        'status': 'Active',
        'paymentStatus': 'Payment Approved',
        'startRentDate': Timestamp.now(),
        'endRentDate': _calculateEndRentDate(payment.durationType),
      });

      // Update data payment
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(payment.id)
          .update({
        'isVerifyPayment': true,
        'status': 'Payment Approved',
      });

      DocumentSnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(payment.reservationId)
          .get();

      String warehouseId = reservationSnapshot['warehouseId'];

      await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(warehouseId)
          .update({
        'isVerifyPayment': true,
        'status': 'Payment Approved',
        'warehouseStatus': 'not available',
      });

      // Tampilkan snackbar atau pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification approved!'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error during approval: $e');
    }
  }

  DateTime _calculateEndRentDate(String durationType) {
    // Tambahkan logika perhitungan endRentDate berdasarkan durationType
    DateTime now = DateTime.now();
    switch (durationType) {
      case '1 Week':
        return now.add(Duration(days: 7));
      case '1 Month':
        return now.add(Duration(days: 30));
      case '1 Year':
        return now.add(Duration(days: 365));
    }

    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reservation ID: ${payment.reservationId}'),
              Text('Warehouse Price: ${payment.warehousePrice}'),
              Text('Payment Method: ${payment.paymentMethod}'),
              Text('Status: ${payment.status}'),
              if (payment.paymentReceiptImageUrl != null)
                CachedNetworkImage(
                  imageUrl: payment.paymentReceiptImageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _rejectVerification,
                    child: Text('Reject Verification'),
                  ),
                  ElevatedButton(
                    onPressed: _approveVerification,
                    child: Text('Approve Verification'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
