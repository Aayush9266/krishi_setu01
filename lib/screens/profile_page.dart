import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:krishi_setu01/Screens/Farmer%20Screens/farmerhomepage.dart';
import 'package:krishi_setu01/screens/Farmer%20Screens/farmerbottomnav.dart';
import '../utils.dart';
import 'Buyer Screens/buyerBottomNavbar.dart';
import 'Buyer Screens/product_listing.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfilePage({required this.userData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  String? _base64Image;

  late List<String> role = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController =
        TextEditingController(text: widget.userData['address']);
    _base64Image = widget.userData['base64image'];
    setrole();
    print(widget.userData);
  }

  void showRoleSelectionDialog(
      BuildContext context, List<String> roles, Map<String, dynamic> userData) {
    String selectedRole =
        widget.userData['roles'][0].toString(); // Default selection

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change User Role"),
          content: roles.length > 1
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: roles.map((role) {
                    return RadioListTile(
                      title: Text(role),
                      value: role,
                      groupValue: selectedRole,
                      onChanged: (value) {
                        selectedRole = value!;
                        setState(() {
                          if (selectedRole == "Buyer") {
                            Map<String, dynamic> data = widget.userData;
                            print(data);
                            data['roles'] = ["Buyer"];
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductListingScreen(
                                        userdata: data,
                                      )),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            Map<String, dynamic> data = widget.userData;
                            data['roles'] = ["Farmer"];
                            print(data);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FHome(userdata: data)),
                              (Route<dynamic> route) => false,
                            );
                          }
                        });

                        // Handle role selection and navigation here
                        // Close dialog after selection
                      },
                    );
                  }).toList(),
                )
              : ElevatedButton(
                  onPressed: () async {
                    // Handle sign-up as a different role
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userData['uid'])
                        .update({
                      'roles': ['Buyer', 'Farmer'],
                    });
                    setState(() {
                      Map<String, dynamic> data = widget.userData;
                      data['roles'] = ['Buyer', 'Farmer'];
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                utils().intermediate(data, context)),
                        (Route<dynamic> route) => false,
                      );
                    });

// Close dialog
                  },
                  child: Text(
                    userData['roles'].contains("Buyer")
                        ? "Sign up as Farmer"
                        : "Sign up as Buyer",
                  ),
                ),
        );
      },
    );
  }

  Future<void> setrole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData['uid'])
        .get();

    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    setState(() {
      role = List<String>.from(data['roles']);
      print(role);
      isLoading = true;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'base64image': base64String,
        });

        setState(() {
          _base64Image = base64String;
          widget.userData['base64image'] = base64String;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update image: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updatedData);

      setState(() {
        widget.userData.addAll(updatedData);
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              utils().logoutUser(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image & Name
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _base64Image != null
                              ? MemoryImage(base64Decode(_base64Image!))
                              : null,
                          child: _base64Image == null
                              ? Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.userData['name'] ?? "No Name",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: TextButton(
                  onPressed: () {
                    showRoleSelectionDialog(context, role, widget.userData);
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Change User Role",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )),
                  )),
              leading: Icon(Icons.change_circle_outlined, size: 28),
              contentPadding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.08, 0, 0, 0),
              shape: Border(
                bottom: BorderSide(color: Colors.grey[350]!, width: 0.8),
                top: BorderSide(color: Colors.grey[350]!, width: 0.8),
              ),
            ),
            SizedBox(height: 20),
            // Update Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Update Information",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800]),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit,
                      color: Colors.green[700]),
                  onPressed: () {
                    if (_isEditing) {
                      _updateProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // User Details Form
            _buildTextField("Name", _nameController),
            _buildTextField("Email", _emailController),
            _buildTextField("Phone", _phoneController),
            _buildTextField("Address", _addressController),
          ],
        ),
      ),
      bottomNavigationBar: (widget.userData['roles'][0].toString() == "Farmer")
          ? FBottomBar(userdata: widget.userData)
          : BBottomBar(userdata: widget.userData),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
        enabled: _isEditing,
      ),
    );
  }
}
