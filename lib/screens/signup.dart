import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _role = 'Farmer'; // Default role
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create User in Firebase Auth
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store User Details in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'roles': [_role],
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'uid': userCredential.user!.uid,
          'cart':[],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Successful!")),
        );

        // Navigate or Clear Fields
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Create Account",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800])),

                    SizedBox(height: 20),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                      items: ["Farmer", "Buyer"]
                          .map((role) =>
                              DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (value) => setState(() => _role = value!),
                    ),
                    SizedBox(height: 10),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                      validator: (value) =>
                          value!.isEmpty ? "Enter your name" : null,
                    ),
                    SizedBox(height: 10),

                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.length != 10
                          ? "Enter a valid phone number"
                          : null,
                    ),
                    SizedBox(height: 10),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: "Email", border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                  .hasMatch(value!)
                              ? "Enter a valid email"
                              : null,
                    ),
                    SizedBox(height: 10),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                          labelText: "Address", border: OutlineInputBorder()),
                      validator: (value) =>
                          value!.isEmpty ? "Enter your address" : null,
                    ),
                    SizedBox(height: 10),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: "Password", border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? "Password must be 6+ chars"
                          : null,
                    ),
                    SizedBox(height: 10),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) => value != _passwordController.text
                          ? "Passwords do not match"
                          : null,
                    ),
                    SizedBox(height: 20),

                    // Signup Button
                    ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
