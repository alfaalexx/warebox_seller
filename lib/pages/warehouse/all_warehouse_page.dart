// AllWarehousesPage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';
import 'package:warebox_seller/model/warehouse_model.dart';

class AllWarehousesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Warehouses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('warehouses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No warehouses found.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((warehouse) {
                final Warehouse currentWarehouse =
                    Warehouse.fromSnapshot(warehouse);

                return ListTile(
                  title: Text(currentWarehouse.itemName),
                  subtitle: Text(currentWarehouse.category),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailWarehousePage(
                          warehouseId: currentWarehouse.id,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}