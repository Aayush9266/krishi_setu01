import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_setu01/screens/profile_page.dart';

class ProductListingScreen extends StatefulWidget {
  final Map<String, dynamic> userdata;

  const ProductListingScreen({Key? key, required this.userdata}) : super(key: key);

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts(); // Load products when widget initializes
  }

  // Function to fetch available products from Firestore
  Future<void> loadProducts() async {
    List<Map<String, dynamic>> productList = await fetchAvailableProducts();
    setState(() {
      products = productList;
      filteredProducts = List.from(products); // Initially show all products
    });
  }

  // Function to fetch product details from Firestore
  Future<List<Map<String, dynamic>>> fetchAvailableProducts() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('products')
          .where('quantity', isGreaterThan: 0)
          .get();

      List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'image': data['base64image'], // Base64 image string
          'product_name': data['productName'],
          'owner': data['owner'],
          'price': data['price'],
          'product_info': data['productInfo'],
          'quantity': data['quantity'],
        };
      }).toList();

      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }


  void filterSearchResults(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
          product['product_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 5),
            const Text("Mumbai, India", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userData: widget.userdata,)));
            },
          )
        ],
      ),
      drawer: Drawer(), // Empty Drawer
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                filled: true,
                fillColor: Colors.green[50],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                var product = filteredProducts[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12)),
                          child: product['image'].isNotEmpty
                              ? Image.memory(
                            base64Decode(product['image']),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                              : Container(
                            color: Colors.green[100],
                            width: double.infinity,
                            child: const Icon(Icons.image, size: 50, color: Colors.green),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          product['product_name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("BUY - ${product['price']}",
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height:10)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



// Product Detail Page
class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['product_name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product['image'].isNotEmpty
                ? Image.memory(base64Decode(product['image']), height: 200)
                : Container(
              height: 200,
              color: Colors.green[100],
              child: const Icon(Icons.image, size: 50, color: Colors.green),
            ),
            const SizedBox(height: 20),
            Text("Product: ${product['product_name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Price: ${product['price']}", style: const TextStyle(fontSize: 16)),
            Text("Quantity: ${product['quantity']}", style: const TextStyle(fontSize: 16)),
            Text("Description: ${product['product_info']}", style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${product['product_name']} purchased successfully!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("CONFIRM PURCHASE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
