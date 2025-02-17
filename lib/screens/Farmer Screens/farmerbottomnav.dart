import 'package:flutter/material.dart';
import 'package:krishi_setu01/Screens/Farmer%20Screens/farmerhomepage.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/Queries.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/analytics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FBottomBar extends StatelessWidget {
  const FBottomBar({Key? key, required this.userdata}) : super(key: key);
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
                          builder: (context) => FHome(userdata: userdata)),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
              Expanded(child: Text("Home", style: TextStyle(color: Colors.white))) // White text
            ]),

            // Queries Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(LucideIcons.messageCircle, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Queries(userdata: userdata)),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
              Expanded(child: Text("Queries", style: TextStyle(color: Colors.white))) // White text
            ]),

            // Analytics Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.analytics, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Analytics(userdata: userdata)),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
              Expanded(child: Text("Dashboard", style: TextStyle(color: Colors.white))) // White text
            ]),

            // Profile Icon - Green Theme
            Column(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.settings_outlined, color: Colors.white), // White icon
                  padding: EdgeInsets.zero,
                  onPressed: () {
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
