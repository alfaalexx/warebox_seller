import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warebox_seller/model/reservation_model.dart';
import 'package:warebox_seller/pages/reservation/detail_reservation_page.dart';

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
        title: Text('My Reservations'),
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

                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      Reservation reservation = reservations[index];
                      return Card(
                        child: ListTile(
                          title:
                              Text('Warehouse ID: ${reservation.warehouseId}'),
                          subtitle: Text(
                              'Duration Type: ${reservation.durationType}'),
                          onTap: () {
                            // Check if the reservation belongs to the current user
                            if (reservation.userUid == currentUser!.uid) {
                              // Navigate to detail page with reservation data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailReservationPage(
                                    reservation: reservation,
                                  ),
                                ),
                              );
                            } else {
                              // Show an error message or handle unauthorized access
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Unauthorized Access'),
                                    content: Text(
                                      'You do not have permission to view this reservation.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
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
