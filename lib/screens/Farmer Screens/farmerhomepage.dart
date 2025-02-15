import 'package:flutter/material.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/APMCmarket.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Inventory.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Queries.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/addproduct.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/analytics.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/weatherReport.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class FarmerHomePage extends StatelessWidget {
  FarmerHomePage({required this.userdata});
  final Map<String,dynamic> userdata;
  final List<Map<String, dynamic>> options = [
    {'title': 'Add Product', 'icon': LucideIcons.circlePlus , 'widget' : Addproduct()},
    {'title': 'Analytics', 'icon': LucideIcons.chartBar , 'widget' : Analytics()},
    {'title': 'APMC Market', 'icon': LucideIcons.store,'widget' : APMC()},
    {'title': 'Weather Report', 'icon': LucideIcons.cloudRain,'widget' : Weather()},
    {'title': 'Inventory', 'icon': LucideIcons.box,'widget' : Inventory()},
    {'title': 'Queries', 'icon': LucideIcons.messageCircle,'widget' : Queries()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Farmer Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Add navigation logic for each option
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  options[index]['widget']),
                );
                print('${options[index]['title']} tapped');
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                color: Colors.green[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(options[index]['icon'], size: 40, color: Colors.green[700]),
                    SizedBox(height: 10),
                    Text(
                      options[index]['title'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
