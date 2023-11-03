import 'package:flutter/material.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';

class DetailWarehousePage extends StatefulWidget {
  final Warehouse warehouse; // Parameter harus dideklarasikan di sini.

  // Ini adalah konstruktor untuk StatefulWidget.
  const DetailWarehousePage({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<DetailWarehousePage> createState() => _DetailWarehousePageState();
}

class _DetailWarehousePageState extends State<DetailWarehousePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Warehouse"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ID: ${widget.warehouse.id}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Name: ${widget.warehouse.itemName}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Category: ${widget.warehouse.category}',
                style: TextStyle(fontSize: 20)),
            // Tambahkan elemen UI lain sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
