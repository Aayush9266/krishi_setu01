import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details.dart';

class OrdersListPage extends StatelessWidget {
  final Map<String, dynamic> userdata;
  const OrdersListPage({super.key, required this.userdata});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.green.shade700, // Dark green header
      ),
      body: Container(
        color: Colors.green.shade50, // Light green background
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('buyer', isEqualTo: userdata['name'])
          // Removed orderBy('timestamp') to avoid Firestore indexing error
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.green));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
              );
            }

            // Sort orders manually by timestamp
            var orders = snapshot.data!.docs.toList();
            orders.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

            return ListView(
              padding: EdgeInsets.all(10),
              children: orders.map((order) {
                return Card(
                  color: Colors.green.shade100, // Light green card
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: Text(
                      'Order #${order.id}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                    ),
                    subtitle: Text(
                      'Total: ₹${order['totalAmount']}',
                      style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailsPage(order: order.data() as Map<String, dynamic>),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
