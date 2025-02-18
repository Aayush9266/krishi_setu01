import 'dart:convert';
import 'package:KrishiSetu/Screens/Buyer%20Screens/buyerBottomNavbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> userData;

  const ProductDetailScreen({super.key, required this.product, required this.userData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? ownerData;
  List<String> cart = [];
  bool isInCart = false;

  @override
  void initState() {
    super.initState();
    fetchOwnerData();
    loadCart();
  }

  /// Fetch Owner Details from Firebase
  Future<void> fetchOwnerData() async {
    String ownerId = widget.product['owner'];
    DocumentSnapshot ownerSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    if (ownerSnapshot.exists) {
      setState(() {
        ownerData = ownerSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  /// Load Cart from SharedPreferences
  Future<void> loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cart = prefs.getStringList('cart') ?? [];
      isInCart = cart.contains(widget.product['id']);
    });
  }

  /// Toggle Cart (Add or Remove Product)
  Future<void> toggleCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (isInCart) {
        cart.remove(widget.product['id']);
      } else {
        cart.add(widget.product['id']);
      }
      isInCart = !isInCart;
    });
    await prefs.setStringList('cart', cart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(widget.product['product_name'],
            style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  widget.product['image'].isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(base64Decode(widget.product['image']),
                        height: 250, width: double.infinity, fit: BoxFit.cover),
                  )
                      : Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image, size: 80, color: Colors.green),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("₹${widget.product['price']}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Available: ${widget.product['quantity']}",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Product Description
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(widget.product['product_info'],
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // Owner Details Card
            if (ownerData != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(ownerData!['name'],
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.chat, color: Colors.green),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/chat', arguments: ownerData);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 5),
                                Text(ownerData!['address'],
                                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: toggleCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.grey : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isInCart ? "ADDED TO CART" : "ADD TO CART",
                  style: TextStyle(
                    color: isInCart ? Colors.black : Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),

      ),
      bottomNavigationBar: BBottomBar(userdata: widget.userData),
    );
  }
}
