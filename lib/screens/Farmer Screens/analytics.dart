import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import 'farmerbottomnav.dart';

class Analytics extends StatefulWidget {
  Map<String,dynamic> userdata;
  Analytics({required this.userdata ,super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  @override
  Widget build(BuildContext context) {
    return SellerDashboard(userdata: widget.userdata);
  }
}


class SellerDashboard extends StatefulWidget {
  Map<String,dynamic> userdata;
  // Seller's name (owner)
  SellerDashboard({required this.userdata, super.key});

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  List<DocumentSnapshot> products = [];
  double totalRevenue = 0;
  Map<String, int> productQuantities = {};
  Map<String, int> bestSellingProducts = {};

  @override
  void initState() {
    super.initState();
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('owner', isEqualTo: widget.userdata['uid'])
        .get();

    double revenue = 0;
    Map<String, int> quantities = {};
    Map<String, int> bestSellers = {};

    for (var doc in snapshot.docs) {
      int price = doc['price'];
      int initialQty = doc['initialQuantity'];
      int currentQty = doc['quantity'];
      int sold = initialQty - currentQty;

      revenue += price * sold;
      quantities[doc['productName']] = currentQty;
      bestSellers[doc['productName']] = sold;
    }

    setState(() {
      products = snapshot.docs;
      totalRevenue = revenue;
      productQuantities = quantities;
      bestSellingProducts = bestSellers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Farmer's Dashboard", style: TextStyle(color: Colors.white)),
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
            _buildTotalRevenueCard(),
            SizedBox(height: 16),
            _buildAvailableQuantityChart(),
            SizedBox(height: 16),
            _buildBestSellingProductsChart(),
            SizedBox(height: 16),
            _buildLowStockTable(),
            SizedBox(height: 16),
            _buildRecentOrdersTable(),
          ],
        ),
      ),
      bottomNavigationBar: FBottomBar(userdata: widget.userdata,),
    );
  }

  // 📊 Total Revenue Card
  Widget _buildTotalRevenueCard() {
    return Card(
      color: Colors.green[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total Revenue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("₹${totalRevenue.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
          ],
        ),
      ),
    );
  }

  // 📊 Available Quantity (Product-wise) - Bar Chart
  Widget _buildAvailableQuantityChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Available Quantity (Product-wise)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[  // Use CartesianSeries instead of ChartSeries
                  BarSeries<MapEntry<String, int>, String>(
                    dataSource: productQuantities.entries.toList(),
                    xValueMapper: (MapEntry<String, int> entry, _) => entry.key,
                    yValueMapper: (MapEntry<String, int> entry, _) => entry.value,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Best Selling Products - Pie Chart
  Widget _buildBestSellingProductsChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Best Selling Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<MapEntry<String, int>, String>(
                    dataSource: bestSellingProducts.entries.toList(),
                    xValueMapper: (MapEntry<String, int> entry, _) => entry.key,
                    yValueMapper: (MapEntry<String, int> entry, _) => entry.value,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📉 Low Stock Products Table
  Widget _buildLowStockTable() {
    List<DocumentSnapshot> lowStockProducts = products..toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Low Stock Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DataTable(
              columns: [
                DataColumn(label: Text("Product Name")),
                DataColumn(label: Text("Quantity")),
              ],
              rows: lowStockProducts.map((doc) {
                return DataRow(cells: [
                  DataCell(Text(doc['productName'])),
                  DataCell(Text(doc['quantity'].toString(), style: TextStyle(color: doc['quantity'] == 0 ? Colors.red : Colors.orange))),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 🛒 Recent Transactions Table
  Widget _buildRecentOrdersTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Recent Transactions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DataTable(
              columns: [
                DataColumn(label: Text("Product")),
                DataColumn(label: Text("Sold")),
                DataColumn(label: Text("Revenue")),
              ],
              rows: products.map((doc) {
                int sold = doc['initialQuantity'] - doc['quantity'];
                double revenue = sold.toDouble() * doc['price'].toDouble();

                return DataRow(cells: [
                  DataCell(Text(doc['productName'])),
                  DataCell(Text(sold.toString())),
                  DataCell(Text("₹${revenue.toStringAsFixed(2)}")),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
