import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:intl/intl.dart';

class MyPaymentPage extends StatefulWidget {
  @override
  _MyPaymentPageState createState() => _MyPaymentPageState();
}

class _MyPaymentPageState extends State<MyPaymentPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Payments',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
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
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPaymentPage(
                                  payment: payment,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reservation ID: ${payment.reservationId}',
                                            style: pjsMedium18,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Payment Method: ${payment.paymentMethod}',
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '${formatRupiah(payment.warehousePrice)}',
                                                  style: pjsSemiBold14Green,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Details',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                child: Text(
                  'Payment Details',
                  style: pjsMedium16,
                ),
              ),

              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Warehouse Price',
                      style: pjsSemiBold14Ls400Grey,
                    ),
                    Text(
                      '${formatRupiah(payment.warehousePrice)}',
                      style: pjsSemiBold14,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Fee (1%)',
                      style: pjsSemiBold14Ls400Grey,
                    ),
                    Text(
                      '${formatRupiah(payment.serviceFee)}',
                      style: pjsSemiBold14,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: pjsSemiBold14Ls400Grey,
                    ),
                    Text(
                      '${formatRupiah(payment.totalAmount)}',
                      style: pjsMedium18,
                    ),
                  ],
                ),
              ),
              if (payment.paymentReceiptImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    imageUrl: payment.paymentReceiptImageUrl!,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),

              // Add more details as needed
            ],
          ),
        ),
      ),
    );
  }
}
