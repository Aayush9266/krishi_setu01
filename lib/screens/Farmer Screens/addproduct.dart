import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';



class AddProduct extends StatefulWidget {
  Map<String,dynamic> userdata;
   AddProduct({required this.userdata ,super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  String? image;

  final ImagePicker picker = ImagePicker();


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int fileSize = await imageFile.length(); // Get image size in bytes

      if (fileSize > 1048487) { // Check if file is larger than 1MB
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Image size must be below 1MB!"))
        );
        return; // Stop further processing
      }

      setState(() {
        _imageFile = imageFile;
      });

      // Convert image to base64 string
      final bytes = await imageFile.readAsBytes();
      String base64String = base64Encode(bytes);
      image = base64String;
    }
  }


  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      String owner = widget.userdata['name'];


      Map<String, dynamic> productData = {
        "productName": _nameController.text.trim(),
        "productInfo": _infoController.text.trim(),
        "price": int.tryParse(_priceController.text.trim()) ?? 0,
        "owner": owner,
        "base64image": image,
        "quantity": int.tryParse(_quantityController.text.trim()) ?? 1,
      };
      await FirebaseFirestore.instance.collection('products').add(productData);
     // await FirebaseFirestore.instance.collection('products').add(newProduct.toMap());

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product Added Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select an image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Add Your Product",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_bag, color: Colors.green),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter product name" : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _infoController,
                        decoration: InputDecoration(
                          labelText: "Product Info",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info, color: Colors.green),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter product info" : null,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: "Price",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? "Enter price" : null,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.production_quantity_limits, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _imageFile != null
                          ? Column(
                        children: [
                          Image.file(_imageFile!, height: 150),
                          TextButton(
                            onPressed: _pickImage,
                            child: Text("Change Image", style: TextStyle(color: Colors.green[700])),
                          ),
                        ],
                      )
                          : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text("Select Image"),
                      ),
                      SizedBox(height: 15),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        onPressed: _addProduct,
                        child: Text("Add Product"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
