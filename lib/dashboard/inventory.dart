import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'addproduct.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
      await http.get(Uri.parse("http://192.168.68.112/devops/get_products.php"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<dynamic> extractedProducts = [];

        for (var category in data) {
          if (category.containsKey("products")) {
            extractedProducts.addAll(category["products"]);
          }
        }

        setState(() {
          products = extractedProducts;
        });
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Error"),
            content: Text("Failed to load products. Please try again."),
            actions: [
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("An unexpected error occurred: $e"),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black, // Dark background
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Inventory",
          style: TextStyle(color: CupertinoColors.white, fontSize: 20),
        ),
        backgroundColor: CupertinoColors.black, // Dark navbar
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16), // Add padding for better spacing
          child: Column(
            children: [
              // Add New Product Button
              CupertinoButton(
                color: CupertinoColors.systemGreen, // Green accent for action
                borderRadius: BorderRadius.circular(10), // Rounded corners
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Add New",
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => AddProductScreen()),
                  ).then((_) => fetchProducts());
                },
              ),
              SizedBox(height: 20), // Add spacing between button and list

              // Product List
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // Handle null values gracefully
                    String name = product["name"] ?? "Unknown Product";
                    String image = product["image"] ?? "placeholder.png";
                    String price = product["price"]?.toString() ?? "0.00";
                    String quantity = product["quantity"]?.toString() ?? "0";

                    return Container(
                      margin: EdgeInsets.only(bottom: 10), // Space between items
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray,
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "http://192.168.68.112/devops/images/$image",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported,
                                    color: CupertinoColors.systemGrey);
                              },
                            ),
                          ),
                          SizedBox(width: 12), // Space between image and text

                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Price: \$${price} | Qty: ${quantity}",
                                  style: TextStyle(
                                    color: CupertinoColors.systemOrange,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}