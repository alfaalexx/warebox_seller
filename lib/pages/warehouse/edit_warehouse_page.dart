import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warebox_seller/pages/warehouse/warehouse_page.dart';
import 'package:warebox_seller/pages/warehouse/detail_warehouse_page.dart';

class EditWarehousePage extends StatefulWidget {
  final Warehouse warehouse;

  const EditWarehousePage({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<EditWarehousePage> createState() => _EditWarehousePageState();
}

class _EditWarehousePageState extends State<EditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse.itemName);
    _categoryController =
        TextEditingController(text: widget.warehouse.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveWarehouse() async {
    if (_formKey.currentState!.validate()) {
      // UID check here
      String? currentUID = FirebaseAuth.instance.currentUser?.uid;
      if (widget.warehouse.uid != currentUID) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You are not authorized to update this warehouse."),
          ),
        );
        return;
      }

      Map<String, dynamic> updatedData = {
        'itemName': _nameController.text,
        'category': _categoryController.text,
        // Add other fields you might need to update
      };

      // Update the Firestore document
      FirebaseFirestore.instance
          .collection('warehouses')
          .doc(widget.warehouse.id)
          .update(updatedData)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Warehouse updated successfully"),
          ),
        );
        Navigator.pop(context, true);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update warehouse: $error"),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Warehouse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWarehouse,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Note: Assuming ID is not editable, so it's not included in the form
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category.';
                }
                return null;
              },
            ),
            // Add other input fields as necessary
          ],
        ),
      ),
    );
  }
}
