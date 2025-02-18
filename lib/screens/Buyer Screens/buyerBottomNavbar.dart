import 'package:flutter/material.dart';
import 'package:krishi_setu01/Screens/Buyer%20Screens/product_listing.dart';
import 'package:krishi_setu01/Screens/Farmer%20Screens/farmerhomepage.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Inventory.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Queries.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/analytics.dart';
import 'package:krishi_setu01/screens/profile_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BBottomBar extends StatelessWidget {
  const BBottomBar({Key? key, required this.userdata}) : super(key: key);
  final Map<String, dynamic> userdata;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.green.shade800, // Deep green background
      elevation: 8, // Add elevation for shadow
      shadowColor: Colors.green.shade600.withOpacity(0.8), // Green shadow
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.home_filled, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductListingScreen(userdata: userdata)),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
              Expanded(child: Text("Home", style: TextStyle(color: Colors.white))) // White text
            ]),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.chat, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => Inventory(userdata: userdata)),
                    //       (Route<dynamic> route) => false,
                    // );
                  },
                ),
              ),
              Expanded(child: Text("Chat", style: TextStyle(color: Colors.white))) // White text
            ]),
            // Queries Icon - Green Theme
            // Column(mainAxisSize: MainAxisSize.min, children: [
            //   Expanded(
            //     child: IconButton(
            //       icon: Icon(LucideIcons.messageCircle, color: Colors.white), // White icon
            //       padding: EdgeInsets.zero,
            //       onPressed: () {
            //         Navigator.pushAndRemoveUntil(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => Queries(userdata: userdata)),
            //               (Route<dynamic> route) => false,
            //         );
            //       },
            //     ),
            //   ),
            //   Expanded(child: Text("Queries", style: TextStyle(color: Colors.white))) // White text
            // ]),

            // Analytics Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => Analytics(userdata: userdata)),
                    //       (Route<dynamic> route) => false,
                    // );
                  },
                ),
              ),
              Expanded(child: Text("Cart", style: TextStyle(color: Colors.white))) // White text
            ]),

            // Profile Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.person, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(userData: userdata)),
                          (Route<dynamic> route) => false,
                    );
                    // Profile action goes here
                  },
                ),
              ),
              Expanded(child: Text("Profile", style: TextStyle(color: Colors.white))) // White text
            ]),
          ],
        ),
      ),
    );
  }
}
