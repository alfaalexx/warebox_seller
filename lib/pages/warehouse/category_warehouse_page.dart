import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';
import 'package:warebox_seller/model/warehouse_model.dart';
import 'package:intl/intl.dart';
import 'package:warebox_seller/utils/custom_themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryWarehousePage extends StatefulWidget {
  final String category;

  const CategoryWarehousePage({Key? key, required this.category})
      : super(key: key);

  @override
  _CategoryWarehousePageState createState() => _CategoryWarehousePageState();
}

class _CategoryWarehousePageState extends State<CategoryWarehousePage> {
  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Warehouses - ${widget.category}',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('warehouses')
            .where('category', isEqualTo: widget.category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No warehouses found.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: snapshot.data!.docs.map((warehouse) {
                  final currentWarehouse = Warehouse.fromSnapshot(warehouse);

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E5E5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailWarehousePage(
                                  warehouseId: currentWarehouse.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  topLeft: Radius.circular(12),
                                ),
                                child: currentWarehouse.warehouseImageUrl !=
                                        null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            currentWarehouse.warehouseImageUrl!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: 100.0,
                                          height: 100.0,
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
                                    : Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .grey[200], // Placeholder color
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            topLeft: Radius.circular(12),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons
                                              .store, // Placeholder icon when image is null
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0),
                                            child: Text(
                                              currentWarehouse.itemName,
                                              style: pjsMedium18,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0),
                                            child: Text(
                                              currentWarehouse.warehouseStatus,
                                              style: currentWarehouse
                                                          .warehouseStatus ==
                                                      'available'
                                                  ? pjsSemiBold14Green
                                                  : pjsSemiBold14Red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: Text(
                                          currentWarehouse.category,
                                          style: pjsMedium16Grey,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Row(
                                          children: [
                                            Text(
                                                formatRupiah(currentWarehouse
                                                    .pricePerMonth),
                                                style: pjsMedium16Tosca2),
                                            Spacer(),
                                            Icon(Icons.star,
                                                color: Colors.amber, size: 20),
                                            Text(
                                              ' (4.8)',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
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
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
