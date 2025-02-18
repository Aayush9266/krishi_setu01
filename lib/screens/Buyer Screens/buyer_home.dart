import 'package:KrishiSetu/Screens/Buyer%20Screens/product_listing.dart';
import 'package:flutter/material.dart';

class BuyerHomeScreen extends StatelessWidget {
  final Map<String, dynamic> userdata;
  const BuyerHomeScreen({required this.userdata, super.key});

  @override
  Widget build(BuildContext context) {
    return ProductListingScreen(
      userdata: userdata,
    );
  }
}
