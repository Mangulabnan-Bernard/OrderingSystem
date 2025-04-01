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
    final response = await http.get(Uri.parse("http://192.168.68.112/devops/get_products.php"));

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
      print("Failed to load products");
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Inventory", style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton.filled(
              child: Text("Add New"),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => AddProductScreen()),
                ).then((_) => fetchProducts());
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  // ✅ Handling null values
                  String name = product["name"] ?? "Unknown Product";
                  String image = product["image"] ?? "placeholder.png";
                  String price = product["price"]?.toString() ?? "0.00";
                  String quantity = product["quantity"]?.toString() ?? "0";

                  return Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Image.network(
                        "http://192.168.68.112/devops/images/$image",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image_not_supported, color: Colors.white);
                        },
                      ),
                      title: Text(name, style: TextStyle(color: Colors.white)),
                      subtitle: Text("Price: \$${price} | Qty: ${quantity}",
                          style: TextStyle(color: Colors.orange)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
