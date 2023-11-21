import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:warebox_seller/pages/reservation/detail_reservation_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:warebox_seller/utils/custom_themes.dart';

class MyReservationPage extends StatefulWidget {
  @override
  _MyReservationPageState createState() => _MyReservationPageState();
}

class _MyReservationPageState extends State<MyReservationPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Reservation',
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
                  .collection('reservations')
                  .where('userUid', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<Reservation> reservations = snapshot.data!.docs
                      .map((DocumentSnapshot document) =>
                          Reservation.fromSnapshot(document))
                      .toList();
                  if (reservations.isNotEmpty) {
                    return ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        Reservation reservation = reservations[index];
                        return FutureBuilder(
                          // Fetch warehouse data based on warehouseId
                          future: FirebaseFirestore.instance
                              .collection('warehouses')
                              .doc(reservation.warehouseId)
                              .get(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot>
                                  warehouseSnapshot) {
                            if (warehouseSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (warehouseSnapshot.hasError) {
                              return Text('Error: ${warehouseSnapshot.error}');
                            } else if (warehouseSnapshot.hasData &&
                                warehouseSnapshot.data!.exists) {
                              // Warehouse data is available
                              Map<String, dynamic> warehouseData =
                                  warehouseSnapshot.data!.data()
                                      as Map<String, dynamic>;

                              String warehouseImageUrl =
                                  warehouseData['warehouseImageUrl'] ?? '';

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    // Navigate to the detail page with reservation data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailReservationPage(
                                          reservation: reservation,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFE5E5E5),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            topLeft: Radius.circular(12),
                                          ),
                                          child: warehouseImageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: warehouseImageUrl,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      CircularProgressIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                )
                                              : Placeholder(
                                                  fallbackWidth: 80,
                                                  fallbackHeight: 80,
                                                ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${warehouseData['itemName']}',
                                                style: pjsMedium18,
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Duration Type: ${reservation.durationType}',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '${reservation.status}',
                                                      style: reservation
                                                                  .status ==
                                                              'Active'
                                                          ? pjsSemiBold14Green
                                                          : pjsSemiBold14Red,
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
                              );
                            } else {
                              // Warehouse data not found
                              return Center(
                                child: Text(
                                    'Warehouse not found for ID: ${reservation.warehouseId}'),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('Reservations not found'),
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
