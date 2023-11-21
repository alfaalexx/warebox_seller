import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:warebox_seller/model/payment_model.dart';
import 'package:warebox_seller/model/warehouse_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:intl/intl.dart';

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
  Warehouse? warehouse;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadReservationAndPaymentData();
  }

  String? getCurrentUserUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
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

        // Load warehouse data
        DocumentSnapshot warehouseSnapshot = await FirebaseFirestore.instance
            .collection('warehouses')
            .doc(reservation?.warehouseId)
            .get();

        if (warehouseSnapshot.exists) {
          setState(() {
            warehouse = Warehouse.fromSnapshot(warehouseSnapshot);
          });
        }
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
        'status': 'Waiting for payment verification',
        'isPaid': true,
        'paidDate': Timestamp.now()
      });

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservation?.id)
          .update({
        'paymentStatus': 'Waiting for payment verification',
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
                    'Reservation Details',
                    style: pjsMedium16,
                  ),
                ),
                if (reservation != null) ...[
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: '${warehouse!.warehouseImageUrl}',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${warehouse!.itemName}',
                                    style: pjsMedium16,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 4, 0, 0),
                                    child: Text(
                                      'Status: ${warehouse!.warehouseStatus}',
                                      style: pjsMedium16Tosca2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reservation ID',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          '${reservation!.id}',
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
                          'Duration Type',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          '${reservation!.durationType}',
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
                          'Status',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          '${reservation!.status}',
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
                          'Payment Status',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          '${reservation!.paymentStatus}',
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
                          'Paid Date',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          payment?.paidDate != null
                              ? DateFormat('dd MMMM yyyy')
                                  .format(payment!.paidDate!)
                              : 'Not specified',
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
                          'Payment Method',
                          style: pjsSemiBold14Ls400Grey,
                        ),
                        Text(
                          '${payment!.paymentMethod}',
                          style: pjsSemiBold14,
                        ),
                      ],
                    ),
                  ),
                ] else
                  Text('Reservation data not available'),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                  child: Divider(
                    thickness: 2,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                  child: Text(
                    'Payment Details',
                    style: pjsMedium16,
                  ),
                ),
                if (payment != null) ...[
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
                          '${formatRupiah(payment!.warehousePrice)}',
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
                          '${formatRupiah(payment!.serviceFee)}',
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
                          '${formatRupiah(payment!.totalAmount)}',
                          style: pjsMedium18,
                        ),
                      ],
                    ),
                  ),
                ] else
                  Text('Payment data not available'),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                  child: Divider(
                    thickness: 2,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                      child: Text(
                        'Payment Receipt',
                        style: pjsMedium16,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Image.asset(
                                    'assets/images/qris_warebox.png.jpeg',
                                    width: 200, // Adjust the width as needed
                                    height: 200, // Adjust the height as needed
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Scan Qris', style: pjsMedium16Tosca2)),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                  child: Text(
                    'Scan Qris and Upload Your Payment Receipt',
                    style: pjsSemiBold14Ls400Grey,
                  ),
                ),
                if (payment?.paymentReceiptImageUrl != null)
                  CachedNetworkImage(
                    imageUrl: payment!.paymentReceiptImageUrl!,
                    placeholder: (context, url) => CircularProgressIndicator(),
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
              ],
            ),
          ),
        ),
      );
    } else
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
  }
}
