import 'package:KrishiSetu/screens/Buyer%20Screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'buyerBottomNavbar.dart';

class CommunityPage extends StatefulWidget {
  CommunityPage({Key? key, required this.userdata}) : super(key: key);
  final Map<String, dynamic> userdata;

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Map<String, dynamic>> _communities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<List<Map<String, dynamic>>> fetchCommunities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('buyer', isEqualTo: widget.userdata['name']) // Filter by buyer
          .get();

      List<Map<String, dynamic>> communities = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID
          ...doc.data() as Map<String, dynamic>, // Document fields
        };
      }).toList();

      return communities;
    } catch (e) {
      print("Error fetching communities: $e");
      return [];
    }
  }


  Future<void> _loadCommunities() async {
    List<Map<String, dynamic>> fetchedCommunities = await fetchCommunities();
    setState(() {
      _communities = fetchedCommunities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _communities.isEmpty
          ? Center(child: Text("No Chats found"))
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(Icons.face,
                          color: Colors.green),
                      title: Text(
                        _communities[index]["farmer"]!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      // subtitle: Text(
                      //   "Admin: ${_communities[index]["admin"]}",
                      //   style: TextStyle(color: Colors.grey[700]),
                      // ),
                      trailing:
                      Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userdata: widget.userdata,
                              RoomId: _communities[index]["groupId"],
                              farmer:  _communities[index]["farmer"],

                            ),
                          ),
                        );
                        }
                    ),
                  );
                },
                childCount: _communities.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BBottomBar(userdata: widget.userdata),
    );
  }
}
