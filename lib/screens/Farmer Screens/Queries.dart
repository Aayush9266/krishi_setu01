import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import 'farmerbottomnav.dart';

class Queries extends StatefulWidget {
  const Queries({Key? key, required this.userdata}) : super(key: key);
  final Map<String, dynamic> userdata;

  @override
  State<Queries> createState() => _QueriesState();
}

class _QueriesState extends State<Queries> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: Text("Queries"),
      backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              utils().logoutUser(context);
            },
          ),
        ],),
      bottomNavigationBar: FBottomBar(userdata: widget.userdata),
    );
  }
}
