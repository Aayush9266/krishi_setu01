import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/Buyer Screens/product_listing.dart';
import '../Screens/Farmer Screens/farmerhomepage.dart';
import '../Screens/login.dart';
import '../screens/role_selection.dart';


class utils{
  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
  Widget intermediate(Map<String,dynamic> userdata , BuildContext context){
    List<dynamic> roles = userdata['roles']; // Get role field (array)

    if (roles.length > 1) {
      // Step 3A: Navigate to Role Selection Page
      return RoleSelectionScreen(userdata: userdata,);

    } else if (roles.length == 1) {
      // Step 3B: Navigate to specific page based on role
      String userRole = roles.first;

      if (userRole == "Farmer") {
        return FHome(userdata: userdata,);

      } else if (userRole == "Buyer") {
        return ProductListingScreen(userdata: userdata,);

      } else {
        throw Exception("Invalid role assigned.");
      }
    } else {
      throw Exception("No role assigned. Please contact support.");
    }
  }
}