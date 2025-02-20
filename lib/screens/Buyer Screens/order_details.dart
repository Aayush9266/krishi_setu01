import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = order['items']; // List of products in the order

    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${order['order_id']}"),
        backgroundColor: Colors.green.shade700, // Dark green header
      ),
      body: Container(
        color: Colors.green.shade50, // Light green background
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buyer: ${order['buyer']}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            SizedBox(height: 10),
            Text(
              "Products:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return Card(
                    color: Colors.green.shade100, // Light green card
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        item['product_name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Quantity: ${item['quantity']}", style: TextStyle(color: Colors.green.shade700)),
                          Text("Price: ₹${item['price']}", style: TextStyle(color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Back to Orders", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
