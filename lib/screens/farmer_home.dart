import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:krishi_setu01/Screens/login.dart';

import 'Farmer Screens/farmerhomepage.dart'; // Import Login Page to redirect after logout

class FarmerHomeScreen extends StatelessWidget {
  FarmerHomeScreen({required this.userdata , super.key});
  final Map<String,dynamic> userdata;

  @override
  Widget build(BuildContext context) {
    // Get current user
   // final User? user = FirebaseAuth.instance.currentUser;

    return FarmerHomePage(userdata: userdata);
  }
}
