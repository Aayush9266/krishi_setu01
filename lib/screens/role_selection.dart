import 'package:flutter/material.dart';
import 'package:krishi_setu01/Screens/Buyer Screens/buyer_home.dart';
import 'package:krishi_setu01/Screens/Buyer%20Screens/product_listing.dart';
import 'package:krishi_setu01/Screens/Farmer Screens/farmerhomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krishi_setu01/Screens/login.dart';

class RoleSelectionScreen extends StatelessWidget {
  Map<String,dynamic> userdata;
  RoleSelectionScreen({required this.userdata ,super.key});
  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Select Your Role"),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Choose your role to continue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            // Farmer Card
            GestureDetector(
              onTap: () {
                userdata['roles'] = ["Farmer"];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FHome(userdata: userdata,)),
                );
              },
              child: _buildRoleCard(
                icon: Icons.agriculture,
                title: "Farmer",
                description: "Sell your farm produce directly to buyers.",
                color: Colors.green[700]!,
              ),
            ),
            const SizedBox(height: 20),
            // Buyer Card
            GestureDetector(
              onTap: () {
                userdata['roles'] = ["Buyer"];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListingScreen(userdata: userdata,)),
                );
              },
              child: _buildRoleCard(
                icon: Icons.shopping_cart,
                title: "Buyer",
                description: "Buy fresh produce directly from farmers.",
                color: Colors.green[500]!,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                logoutUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text("LOGOUT", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role Card Widget
  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

