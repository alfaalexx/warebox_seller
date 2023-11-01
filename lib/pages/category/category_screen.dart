import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warebox_seller/model/category_model.dart';
import 'package:warebox_seller/pages/category/add_category_screen.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Category Management',
          textAlign: TextAlign.start,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2E9496),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddCategory()),
          );
        },
      ),
      body: const DriverList(),
    );
  }
}

class DriverList extends StatelessWidget {
  const DriverList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data?.docs;
        return ListView.builder(
          itemCount: documents!.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            final driver = CategoryModel.fromSnapshot(document);
            final imageUrl = driver.imageUrl;
            final docId = document.id; 

            return Card(
              margin: const EdgeInsets.only(top: 16.0),
              child: Container(
                height: 100,
                child: Center(
                  child: ListTile(
                    leading: Image.network(
                      imageUrl,
                      width: 100,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    title: Text(driver.name), 
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        deleteDriver(docId);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void deleteDriver(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
    } catch (e) {
      print('Error deleting driver: $e');
    }
  }
}
