import 'dart:convert';
import 'package:KrishiSetu/Screens/Buyer%20Screens/buyerBottomNavbar.dart';
import 'package:KrishiSetu/screens/Buyer%20Screens/product_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> userdata;
  const CartPage({super.key, required this.userdata});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> cartIds = [];
  Map<String, int> selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc = await firestore.collection('users').doc(widget.userdata['uid']).get();
    List<Map<String, dynamic>> storedCart = List<Map<String, dynamic>>.from(userDoc.get('cart') ?? []);

    setState(() {
      cartIds = storedCart;
    });

    fetchCartProducts();
  }

  Future<void> fetchCartProducts() async {
    if (cartIds.isEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> products = [];

    for (Map<String, dynamic> id in cartIds) {
      DocumentSnapshot doc = await firestore.collection('products').doc(id['product_id']).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        products.add(data);
        selectedQuantities[doc.id] = id['quantity'];
      }
    }

    setState(() {
      cartItems = products;
    });
  }

  Future<void> updateCartQuantity(String productId, int newQuantity) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    for (var item in cartIds) {
      if (item['product_id'] == productId) {
        item['quantity'] = newQuantity;
      }
    }
    await firestore.collection('users').doc(widget.userdata['uid']).update({'cart': cartIds});
  }

  void updateQuantity(String productId, int change, int availableQuantity) {
    setState(() {
      int newQuantity = (selectedQuantities[productId] ?? 1) + change;
      if (newQuantity > 0 && newQuantity <= availableQuantity) {
        selectedQuantities[productId] = newQuantity;
        updateCartQuantity(productId, newQuantity);
      }
    });
  }

  Future<void> removeFromCart(String productId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    cartIds.removeWhere((item) => item['product_id'] == productId);
    await firestore.collection('users').doc(widget.userdata['uid']).update({'cart': cartIds});

    setState(() {
      cartItems.removeWhere((product) => product['id'] == productId);
    });
  }

  double calculateTotal() {
    double total = 0.0;
    for (var product in cartItems) {
      int quantity = selectedQuantities[product['id']] ?? 1;
      total += product['price'] * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProductListingScreen(userdata: widget.userdata)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty!", style: TextStyle(fontSize: 18)))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: cartItems.map((product) {
                  bool isAvailable = product['quantity'] > 0;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: isAvailable ? BorderSide.none : const BorderSide(color: Colors.red, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(product['base64image']),
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product['productName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text("₹${product['price']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                if (isAvailable)
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => updateQuantity(product['id'], -1, product['quantity'])),
                                      Text("${selectedQuantities[product['id']] ?? 1}", style: const TextStyle(fontSize: 16)),
                                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => updateQuantity(product['id'], 1, product['quantity'])),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // Bid & Chat Button
                          IconButton(
                            icon: const Icon(Icons.gavel, color: Colors.green),
                            onPressed: () {
                              // Implement bidding or chat functionality
                            },
                          ),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => removeFromCart(product['id'])),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Billing Section
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 2),
              ],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bill Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // List of Products in Bill
                Column(
                  children: cartItems.map((product) {
                    int quantity = selectedQuantities[product['id']] ?? 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product['productName'],
                              style: const TextStyle(fontSize: 16)),
                          Text("₹${product['price']} x $quantity",
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const Divider(thickness: 1),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grand Total:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${calculateTotal()}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 12),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement place order functionality
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Place Order",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BBottomBar(userdata: widget.userdata),
    );
  }
}
