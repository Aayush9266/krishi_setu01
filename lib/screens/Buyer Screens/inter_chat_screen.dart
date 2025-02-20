import 'package:KrishiSetu/screens/Buyer%20Screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class InterChatScreen extends StatefulWidget {

  InterChatScreen(
      {Key? key,
        required this.userdata,
        required this.farmer

      })
      : super(key: key);
  final Map<String, dynamic> userdata;
  String farmer;

  @override
  State<InterChatScreen> createState() => _InterChatScreenState();
}

class _InterChatScreenState extends State<InterChatScreen> {
  String? name = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

fetch(widget.farmer);

  }
  Future<void> fetch(String uid)async {
    String? d = await fetchUsername(widget.farmer);
    setState(()  {
      name = d;
    });
  }
  Future<String?> fetchUsername(String uid) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['username']; // Ensure 'username' is a field in your Firestore document
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  ChatScreen(userdata: widget.userdata, RoomId: widget.userdata['name']+name, farmer: name ??" ");
  }
}
