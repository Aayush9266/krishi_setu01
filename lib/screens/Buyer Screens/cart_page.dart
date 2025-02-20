import 'dart:convert';
import 'package:KrishiSetu/Screens/Buyer%20Screens/buyerBottomNavbar.dart';
import 'package:KrishiSetu/screens/Buyer%20Screens/inter_chat_screen.dart';
import 'package:KrishiSetu/screens/Buyer%20Screens/product_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic> userdata;
  const CartPage({super.key, required this.userdata});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> cartIds = [];
  Map<String, int> selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }
  void showOrderPopup() {
    TextEditingController addressController = TextEditingController();
    addressController.text = widget.userdata['address'];
    String selectedPaymentMethod = 'Cash on Delivery';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Order Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Enter Address"),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPaymentMethod,
                items: ['Cash on Delivery', 'UPI', 'Debit Card', 'Credit Card']
                    .map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                placeOrder(addressController.text, selectedPaymentMethod);
                Navigator.of(context).pop();
              },
              child: Text("Place Order"),
            ),
          ],
        );
      },
    );
  }

  Future<void> placeOrder(String address, String paymentMethod) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId = widget.userdata['uid'];

    try {
      // Retrieve the user document
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User not found');
        return;
      }

      // Get the cart array from userdata
      List<dynamic> cart = (userDoc.data() as Map<String, dynamic>)['cart'] ?? [];

      if (cart.isEmpty) {
        print('Cart is empty');
        return;
      }

      double totalAmount = 0;
      for (var item in cart) {
        totalAmount += (item['price'] ?? 0) * (item['quantity'] ?? 1);
      }

      // Create order document
      String orderId = firestore.collection('orders').doc().id;

      // Create order document
      await firestore.collection('orders').doc(orderId).set({
        'order_id': orderId, // Store the unique order ID
        'buyer': widget.userdata['name'],
        'buyer_uid': userId,
        'items': cart,
        'totalAmount': totalAmount,
        'address': address,
        'paymentMethod': paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reduce product quantity in Firestore
      for (var item in cart) {
        String productId = item['product_id'];
        int quantityOrdered = item['quantity'];

        DocumentReference productRef = firestore.collection('products').doc(productId);
        DocumentSnapshot productDoc = await productRef.get();

        if (productDoc.exists) {
          int currentQuantity = (productDoc.data() as Map<String, dynamic>)['quantity'] ?? 0;
          int newQuantity = currentQuantity - quantityOrdered;

          if (newQuantity < 0) newQuantity = 0; // Ensure quantity doesn't go negative

          await productRef.update({'quantity': newQuantity});
        }
      }

      // Clear cart after order placement
      await firestore.collection('users').doc(userId).update({'cart': []});

      print('Order placed successfully');
    } catch (e) {
      print('Error placing order: $e');
    }
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
    if (cartIds.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> products = [];

    for (Map<String, dynamic> id in cartIds) {
      DocumentSnapshot doc = await firestore.collection('products').doc(id['product_id']).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
       // data['ownerName'] = await fetchUsername(data['owner']);

        data['id'] = doc.id;
        products.add(data);
        selectedQuantities[doc.id] = id['quantity'];
      }
    }

    setState(() {
      cartItems = products;
      isLoading = false;
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        // iconTheme: const IconThemeData(color: Colors.white),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(builder: (context) => ProductListingScreen(userdata: widget.userdata)),
        //           (Route<dynamic> route) => false,
        //     );
        //   },
        // ),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) :
      cartItems.isEmpty
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
                            onPressed: ()  {
                              // String owner = product['owner'];
                              // // String roomName = widget.userdata['name']+owner;
                              // // await FirebaseFirestore.instance.collection('chats').doc(roomName).set({
                              // //   'groupId': roomName,
                              // //   'buyer': widget.userdata['name'],
                              // //   'farmer': owner,
                              // // });
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => InterChatScreen(userdata: widget.userdata,farmer:owner,)));
                              // // Implement bidding or chat functionality
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
                  showOrderPopup();
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
