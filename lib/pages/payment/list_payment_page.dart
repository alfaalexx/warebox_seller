import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
// Import model pembayaran

class MyPaymentPage extends StatefulWidget {
  @override
  _MyPaymentPageState createState() => _MyPaymentPageState();
}

class _MyPaymentPageState extends State<MyPaymentPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Payments'),
      ),
      body: currentUser != null
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('payments')
                  .where('userUid', isEqualTo: currentUser!.uid)
                  .where('isPaid', isEqualTo: true)
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
  final Payment payment;

  const DetailPaymentPage({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
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
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
