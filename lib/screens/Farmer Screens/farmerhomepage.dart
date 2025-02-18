import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/APMCmarket.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Inventory.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Queries.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/addproduct.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/analytics.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/farmerbottomnav.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/weatherReport.dart';
import 'package:krishi_setu01/utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class FHome extends StatefulWidget {
  FHome({required this.userdata});
  final Map<String,dynamic> userdata;

  @override
  State<FHome> createState() => _FHomeState();
}

class _FHomeState extends State<FHome> {
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Auto scroll every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        if (_pageController.page == 3) {
          // If the last page is reached, go back to the first page
          _pageController.jumpToPage(0);
        } else {
          _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FarmerHomePage(
        userdata: widget.userdata,
        pageController: _pageController,  // Pass the PageController to FarmerHomePage
        
      ),
    );
  }
}

class FarmerHomePage extends StatelessWidget {
  FarmerHomePage({required this.userdata, required this.pageController});
  final Map<String,dynamic> userdata;
  final PageController pageController;  // Declare the PageController

  @override
  Widget build(BuildContext context) {
    List<String> advertisements = [
      'assets/adv1.jpg', // Replace with your image paths
      'assets/adv2.jpg',
      'assets/adv3.jpg',
      'assets/adv4.jpg',
    ];

    List<Map<String, dynamic>> options = [
      {'title': 'Add Product', 'icon': LucideIcons.circlePlus , 'widget' : AddProduct(userdata: userdata,)},
      {'title': 'Dashboard', 'icon': LucideIcons.chartBar , 'widget' : Analytics(userdata: userdata,)},
      {'title': 'APMC Market', 'icon': LucideIcons.store,'widget' : APMC()},
      {'title': 'Weather Report', 'icon': LucideIcons.cloudRain,'widget' : Weather()},
      {'title': 'Inventory', 'icon': LucideIcons.box,'widget' : Inventory(userdata: userdata,)},
      {'title': 'Queries', 'icon': LucideIcons.messageCircle,'widget' : Queries(userdata: userdata,)},
    ];

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Farmer Homepage', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              utils().logoutUser(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,  // Set a fixed height for the ads
                child: PageView.builder(
                  controller: pageController,  // Use the passed PageController
                  itemCount: advertisements.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          advertisements[index],
                          fit: BoxFit.cover,
                          width: 300,  // Width of each ad
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 500,  // Fixed height for the GridView
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
              ),
            ]
        ),
      ),
      bottomNavigationBar: FBottomBar(userdata: userdata),
    );
  }
}
