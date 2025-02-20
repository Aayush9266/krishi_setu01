import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';

import 'editproduct.dart';
import 'farmerbottomnav.dart';

class Inventory extends StatefulWidget {
  Map<String, dynamic> userdata;
  Inventory({required this.userdata, super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  @override
  Widget build(BuildContext context) {
    return ProductGridPage(userdata: widget.userdata);
  }
}


class ProductGridPage extends StatefulWidget {
  final Map<String, dynamic> userdata;
  ProductGridPage({required this.userdata, super.key});

  @override
  _ProductGridPageState createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  List<DocumentSnapshot> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }
  void _editProduct(DocumentSnapshot product) {
    Product p =
    Product(product['productName'], product['price'], product['initialQuantity'], product['productInfo'], product['owner'],product['base64image'], product['quantity']);
    // Open the Edit Product Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateProductPage(product: p);
      },
    );
  }
  Future<void> _fetchProducts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('owner', isEqualTo: widget.userdata['uid'])
        .get();

    setState(() {
      products = snapshot.docs;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Inventory", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
          Icon(Icons.notifications ,color: Colors.white,)
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProductGrid(),
          ],
        ),
      ),
      bottomNavigationBar: FBottomBar(userdata: widget.userdata),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true, // Allows GridView to take only the required space
      physics: NeverScrollableScrollPhysics(), // Disable scrolling inside GridView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        crossAxisSpacing: 16.0, // Spacing between columns
        mainAxisSpacing: 16.0, // Spacing between rows
        childAspectRatio: 0.75, // Adjust the size ratio to prevent overflow
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        String base64Image = product['base64image'];
        Image productImage;

        if (base64Image.isNotEmpty) {
          productImage = Image.memory(
            base64Decode(base64Image),
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
          );
        } else {
          productImage = Image.asset(
            'assets/default_image.png', // Placeholder image
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
          );
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: SingleChildScrollView( // Make content scrollable inside the card
              child:Column(
            children: [
              ElevatedButton(
                onPressed: () => _editProduct(product),
                child: Text("Edit"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  minimumSize: Size(double.infinity, 36), // Full-width button
                ),
              ),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['productName'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // Truncate long text
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${product['price']}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Qty: ${product['quantity']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: productImage,
                      ),



                    ],
                                  ),
                  ),
                ),

        ],
        )
            )
        ));
      },
    );
  }
}
