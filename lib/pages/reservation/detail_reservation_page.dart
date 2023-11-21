import 'package:flutter/material.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/payment/payment_warehouse_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:intl/intl.dart';

import '../../utils/color_resources.dart';

class DetailReservationPage extends StatefulWidget {
  final Reservation reservation;

  DetailReservationPage({Key? key, required this.reservation})
      : super(key: key);

  @override
  _DetailReservationPageState createState() => _DetailReservationPageState();
}

class _DetailReservationPageState extends State<DetailReservationPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<Map<String, dynamic>> warehouseData;

  @override
  void initState() {
    super.initState();
    warehouseData = _loadWarehouseData();
  }

  Future<Map<String, dynamic>> _loadWarehouseData() async {
    try {
      // Load warehouse data
      DocumentSnapshot warehouseSnapshot = await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.reservation.warehouseId)
          .get();

      if (warehouseSnapshot.exists) {
        // Warehouse data found, do something with it
        Map<String, dynamic> warehouseData =
            warehouseSnapshot.data() as Map<String, dynamic>;

        // Load user data
        String userUid = warehouseData['uid'];
        warehouseData['userData'] = await _loadUserData(userUid);

        return warehouseData;
      } else {
        // Warehouse data not found
        print('Warehouse not found for ID: ${widget.reservation.warehouseId}');
        return {}; // Return an empty map if warehouse data not found
      }
    } catch (e) {
      // Handle error
      print('Error loading data: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  Future<Map<String, dynamic>> _loadUserData(String userUid) async {
    try {
      // Load user data
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('profile')
          .doc(userUid)
          .get();

      if (userSnapshot.exists) {
        // User data found, do something with it
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        return userData;
      } else {
        // User data not found
        print('User not found for UID: $userUid');
        return {}; // Return an empty map if user data not found
      }
    } catch (e) {
      // Handle error
      print('Error loading user data: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  Future<void> handleCancelPayment(BuildContext context) async {
    final reservationRef = FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservation.id);

    try {
      // Use a batch to delete both documents
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Verify the existence of the 'payments' document
      DocumentSnapshot reservationSnapshot = await reservationRef.get();

      if (reservationSnapshot.exists) {
        // If the reservation document exists, get the reservation data
        Reservation reservationData =
            Reservation.fromSnapshot(reservationSnapshot);

        DocumentReference paymentRef = FirebaseFirestore.instance
            .collection('payments')
            .doc(reservationData.paymentId);

        batch.delete(paymentRef);
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
          reservationID: widget.reservation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canModifyPayment =
        currentUser != null && currentUser!.uid == widget.reservation.userUid;
    bool isPaymentUnpaid = widget.reservation.paymentStatus == 'Unpaid';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservation Details',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: warehouseData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Display your UI with warehouse data
            Map<String, dynamic> warehouseData = snapshot.data ?? {};

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 297,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: warehouseData['warehouseImageUrl'] ?? '',
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 24, right: 24, top: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  warehouseData['itemName'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: const Color(0xFF1E2022),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset("assets/images/star.png"),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        "(4.9)",
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1,
                                            color: const Color(0xFF77838F)),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Container(
                              width: 171,
                              margin: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                warehouseData['location'] ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                    color: const Color(0xFF979797)),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Information",
                                style: pjsSemiBold14Ls,
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Reservation ID",
                                      style: pjsSemiBold14Ls400),
                                  Text("${widget.reservation.id}",
                                      style: pjsSemiBold14Ls400Grey),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Status", style: pjsSemiBold14Ls400),
                                  Text("${widget.reservation.status}",
                                      style:
                                          widget.reservation.status == 'Active'
                                              ? pjsSemiBold14Green
                                              : pjsSemiBold14Red),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Payment Status",
                                      style: pjsSemiBold14Ls400),
                                  Text("${widget.reservation.paymentStatus}",
                                      style: pjsSemiBold14Ls400Grey),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Duration Type",
                                      style: pjsSemiBold14Ls400),
                                  Text("${widget.reservation.durationType}",
                                      style: pjsSemiBold14Ls400Grey),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Start Rent", style: pjsSemiBold14Ls400),
                                  Text(
                                      widget.reservation.startRentDate != null
                                          ? DateFormat('dd MMMM yyyy').format(
                                              widget.reservation.startRentDate!)
                                          : 'Not specified',
                                      style: pjsSemiBold14Ls400Grey),
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("End Rent", style: pjsSemiBold14Ls400),
                                  Text(
                                      widget.reservation.endRentDate != null
                                          ? DateFormat('dd MMMM yyyy').format(
                                              widget.reservation.endRentDate!)
                                          : 'Not specified',
                                      style: pjsSemiBold14Ls400Grey),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: const Color(0xFFFFFFFF),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    margin: const EdgeInsets.only(right: 15.0),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        warehouseData['userData']
                                                ['profile_image'] ??
                                            '',
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${warehouseData['userData']['username'] ?? ''}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                          color: const Color(0xFF202222),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "Owner",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1,
                                          color: const Color(0xFF959FA1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/Icon_wa.png",
                                    height: 19,
                                    width: 19,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Hubungi",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                        color: const Color(0xFF202222),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (canModifyPayment && isPaymentUnpaid)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        handleCancelPayment(context),
                                    child: Text('Cancel Payment'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              if (canModifyPayment && isPaymentUnpaid)
                                const SizedBox(
                                    width: 8.0), // Add spacing between buttons
                              if (canModifyPayment && isPaymentUnpaid)
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        handleContinuePayment(context),
                                    child: Text('Continue Payment'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
