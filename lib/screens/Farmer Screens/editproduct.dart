import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';

class UpdateProductPage extends StatefulWidget {
  final Product product;

  UpdateProductPage({required this.product});

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productInfoController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _initialquantityController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with current product data
    _productNameController.text = widget.product.getProductName;
    _productInfoController.text = widget.product.getProductInfo;
    _priceController.text = widget.product.getPrice.toString();
    _quantityController.text = widget.product.getQuantity.toString();
    _initialquantityController.text = widget.product.getInitialQuantity.toString();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Get values from controllers
      String updatedProductName = _productNameController.text;
      String updatedProductInfo = _productInfoController.text;
      int updatedPrice = int.tryParse(_priceController.text) ?? 0;
      int newQuantity = int.tryParse(_quantityController.text) ?? 0;
      int newIni = int.tryParse(_initialquantityController.text) ?? 0;

      // Add the new quantity to the existing product
      widget.product.addQuantity(newQuantity);

      // Update the product details
      // Get the document with the matching productName
      var productQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isEqualTo: widget.product.getProductName)
          .limit(1) // Ensure only one document is fetched
          .get();

      if (productQuery.docs.isNotEmpty) {
        // Get the document ID of the product
        String docId = productQuery.docs[0].id;

        // Update the document
        await FirebaseFirestore.instance.collection('products').doc(docId).update({
          'productName': updatedProductName,
          'productInfo': updatedProductInfo,
          'price': updatedPrice,
          'quantity': newQuantity,
          'base64image': widget.product.getImage, // Updated base64 image
          'initialQuantity': newIni, // Updated initial quantity
        });

        // After updating, show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        // If no matching product is found, handle it
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found!')),
        );
      }

      setState(() {
        _isLoading = false;
      });

      // After updating, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully!')),
      );

      // Optionally, navigate to another page or refresh the data
      Navigator.pop(context); // Go back to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Product", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                      Text("Update Your Product",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_bag, color: Colors.green),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter product name" : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _productInfoController,
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
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _initialquantityController,
                              decoration: InputDecoration(
                                labelText: "Total Quantiity",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? "Enter total quantity" : null,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: "Available Quantity",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.production_quantity_limits, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? "Enter available quantity" : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        onPressed: _updateProduct,
                        child: Text("Update Product"),
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
