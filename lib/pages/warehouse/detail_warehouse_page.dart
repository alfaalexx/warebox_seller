import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/pages/warehouse/edit_warehouse_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';

import '../../utils/color_resources.dart';

class DetailWarehousePage extends StatefulWidget {
  final String warehouseId;
  // Parameter harus dideklarasikan di sini.

  // Ini adalah konstruktor untuk StatefulWidget.
  const DetailWarehousePage({Key? key, required this.warehouseId})
      : super(key: key);

  @override
  State<DetailWarehousePage> createState() => _DetailWarehousePageState();
}

class _DetailWarehousePageState extends State<DetailWarehousePage> {
  Stream<DocumentSnapshot>? warehouseStream;
  Warehouse? warehouse;

  @override
  void initState() {
    super.initState();
    _loadWarehouseData();
  }

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  Future<void> deleteWarehouseImages(List<String> imageUrls) async {
    for (String imageUrl in imageUrls) {
      // Mengubah setiap URL gambar menjadi referensi storage
      Reference storageReference =
          FirebaseStorage.instance.refFromURL(imageUrl);

      // Menghapus gambar dari storage
      await storageReference.delete().catchError((e) => print(e));
    }
  }

  void _deleteWarehouse(BuildContext context) async {
    // Show confirmation dialog before deleting
    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    if (confirmDelete) {
      // Ambil gambar utama dan detail gambar untuk dihapus
      List<String> imageUrls = [];
      if (warehouse!.warehouseImageUrl != null) {
        imageUrls.add(warehouse!.warehouseImageUrl!);
      }
      if (warehouse!.detailImageUrls != null) {
        imageUrls.addAll(warehouse!.detailImageUrls!);
      }

      // Hapus gambar dari Firebase Storage
      await deleteWarehouseImages(imageUrls);
      // Proceed with deletion
      await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouseId)
          .delete();

      // After deletion, pop out of the details page
      Navigator.of(context).pop(true); // true indicates something was deleted
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this warehouse?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Do not delete
                  },
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Proceed with deletion
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Future<Map<String, dynamic>?> getUserProfileData(String uid) async {
    try {
      DocumentSnapshot userProfileSnapshot =
          await FirebaseFirestore.instance.collection('profile').doc(uid).get();

      if (userProfileSnapshot.exists) {
        return userProfileSnapshot.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user profile data: $e');
      return null;
    }
  }

  void _loadWarehouseData() async {
    try {
      DocumentSnapshot warehouseSnapshot = await FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouseId)
          .get();

      if (warehouseSnapshot.exists) {
        // Only update the state if the widget is still mounted
        if (mounted) {
          setState(() {
            warehouse = Warehouse.fromSnapshot(warehouseSnapshot);
          });
        }
      } else {
        // Handle the case where the warehouse document does not exist.
        if (mounted) {
          setState(() {
            // You could update the state to show some message to the user
            // For example, set `warehouse` to `null` or show a snackbar...
            warehouse = null;
          });
        }
      }
    } catch (e) {
      // Handle the error, e.g., by showing an error message to the user
      if (mounted) {
        setState(() {
          // Set `warehouse` to `null` or log the error
          warehouse = null;
        });
      }
    }
  }

  void _navigateAndEditWarehouse(BuildContext context) async {
    if (warehouse != null) {
      // Check if warehouse is not null
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditWarehousePage(
              warehouse: warehouse!), // Pass the non-null warehouse
        ),
      );

      if (result == true) {
        _loadWarehouseData(); // Reload the data after editing
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if warehouse is loaded
    if (warehouse == null) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show a loading indicator
      );
    } else {
      return Scaffold(
        backgroundColor: Color(0xFFF2F5F9),
        appBar: AppBar(
          title: Text(
            'Details',
            textAlign: TextAlign.start,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            // Icon Button Untuk Edit Warehouse
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                _navigateAndEditWarehouse(context);
              },
            ),
            // Icon Button untuk Hapus Warehouse
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteWarehouse(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(14, 14, 0, 14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: warehouse!.warehouseImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: warehouse!.warehouseImageUrl!,
                                  fit: BoxFit.fill,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Icon(Icons.image, size: 100),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align text to the left side
                            children: [
                              Text(
                                '${warehouse!.category}',
                                style: pjsMedium16Tosca,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  '${warehouse!.itemName}',
                                  style: pjsMedium18,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  '${warehouse!.location}',
                                  style: pjsMedium12Grey,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/Icon_ruler.png"),
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '${warehouse!.itemLarge} m²',
                                      style: pjsMedium16Grey,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            '${formatRupiah(warehouse!.pricePerMonth)} ',
                                        style:
                                            pjsMedium16Tosca2, // Your existing style for 'Rp. 300.000'
                                      ),
                                      TextSpan(
                                        text: '/ Month',
                                        style: pjsMedium12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              FutureBuilder<Map<String, dynamic>?>(
                future: getUserProfileData(warehouse!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var userProfile = snapshot.data!;
                    return Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
                            child: ClipOval(
                              child: userProfile['profile_image'] != null
                                  ? CachedNetworkImage(
                                      imageUrl: userProfile['profile_image'],
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Container(
                                      // This is the placeholder for when the image is null
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[200],
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                            ),
                          ),
                          Text(" ${userProfile['username']}",
                              style: pjsMedium16),
                          Spacer(),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/Icon_wa.png",
                                ),
                                SizedBox(width: 5),
                                Text("Hubungi", style: pjsMedium16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('User profile not found.');
                  }
                },
              ),
              SizedBox(height: 25),
              ExpandableNotifier(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Expanded(
                    child: Column(
                      children: [
                        ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToExpand: true,
                            tapBodyToCollapse: true,
                            hasIcon: true,
                            iconColor: Colors.black,
                          ),
                          header: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            child: Text(
                              "Warehouse Description",
                              style: pjsMedium16,
                            ),
                          ),
                          collapsed: Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, bottom: 14),
                            child: Text(
                              "${warehouse!.itemDescription}",
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: pjsMedium16Grey,
                            ),
                          ),
                          expanded: Padding(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, bottom: 14),
                            child: Text(
                              "${warehouse!.itemDescription}",
                              softWrap: true,
                              style: pjsMedium16Grey,
                            ),
                          ),
                          builder: (_, collapsed, expanded) {
                            return Expandable(
                              collapsed: collapsed,
                              expanded: expanded,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: double.infinity,
                child: Text("Warehouse Features", style: pjsMedium16),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Wrap(
                    spacing: 8.0, // Adjust the spacing between features
                    children: warehouse!.features.map((feature) {
                      return Chip(
                        label: Text(feature),
                        backgroundColor: Colors.grey[300],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: double.infinity,
                child: Text("Detail Warehouse", style: pjsMedium16),
              ),
              SizedBox(height: 16),
              warehouse!.detailImageUrls != null &&
                      warehouse!.detailImageUrls!.isNotEmpty
                  ? Container(
                      height:
                          200, // Atur tinggi container sesuai dengan kebutuhan
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: warehouse!.detailImageUrls!.length,
                        itemBuilder: (context, index) {
                          String imageUrl = warehouse!.detailImageUrls![index];
                          return Container(
                            width: MediaQuery.of(context).size.width *
                                0.8, // Atur lebar card sesuai dengan kebutuhan
                            padding: EdgeInsets.symmetric(
                                horizontal: 10), // Atur padding horizontal
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Atur radius border card
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 200,
                      child: Center(child: Text('No images available')),
                    ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10.0), // Add some padding if needed
          child: ElevatedButton(
            onPressed: () {
              // Your button press code here
            },
            child: Text('Reservation', style: pjsExtraBold20),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorResources.wareboxTosca,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ), // Set the button size
            ),
          ),
        ),
      );
    }
  }
}
