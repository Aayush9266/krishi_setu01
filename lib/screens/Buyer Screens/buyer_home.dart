import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krishi_setu01/Screens/login.dart';
import 'package:krishi_setu01/Screens/Buyer Screens/product_listing.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import Login Page to redirect after logout

class BuyerHomeScreen extends StatelessWidget {
  final Map<String,dynamic> userdata;
  const BuyerHomeScreen({required this.userdata ,super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user
    final User? user = FirebaseAuth.instance.currentUser;
    Future<void> logoutUser(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyer Home"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              logoutUser(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Replace with actual user data object
                Map<String, dynamic> userData = {
                  "uid": "123456",
                  "name": "John Doe",
                  "email": "johndoe@example.com",
                  "role": "Buyer",  // or "Farmer"
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(userData: userdata),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Green Theme
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Go to Product Listings",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            Text(
              "Welcome to Krishi Setu!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            Text(
              user != null ? "Logged in as: ${user.email}" : "No user logged in",
              style: TextStyle(fontSize: 16, color: Colors.green[600]),
            ),
            Text(userdata['roles'].toString()),
         //   Text(userdata['roles'].length),
            const SizedBox(height: 20),
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
}
