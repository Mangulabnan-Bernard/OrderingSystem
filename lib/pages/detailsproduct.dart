import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cart.dart';

class MilkTeaDetailsScreen extends StatefulWidget {
  final dynamic product;
  final List<Map<String, dynamic>> cartItems;
  final ValueChanged<List<Map<String, dynamic>>> onCartUpdated;

  const MilkTeaDetailsScreen({
    super.key,
    required this.product,
    required this.cartItems,
    required this.onCartUpdated,
  });

  @override
  _MilkTeaDetailsScreenState createState() => _MilkTeaDetailsScreenState();
}

class _MilkTeaDetailsScreenState extends State<MilkTeaDetailsScreen> {
  int quantity = 1;
  String selectedSize = "Medium";
  int selectedSugarLevel = 0;

  final Map<String, double> sizePriceChange = {
    "Small": -0.50,
    "Medium": 0.00,
    "Large": 1.00,
  };

  final List<int> sugarLevels = [0, 25, 50, 75, 100];

  double get adjustedPrice {
    double basePrice = double.tryParse(widget.product["price"]) ?? 0.0;
    return basePrice + sizePriceChange[selectedSize]!;
  }

  void showSuccessMessage(BuildContext context) {


  }

  Future<void> addToCart(BuildContext context) async {
    // Simulate adding to cart without backend
    List<Map<String, dynamic>> updatedCart = List.from(widget.cartItems)
      ..add({
        "id": widget.product["id"], // Include the product ID
        "name": widget.product["name"],
        "price": adjustedPrice,
        "quantity": quantity,
        "size": selectedSize,
        "sugarLevel": selectedSugarLevel,
        "image": widget.product["image"],
      });

    widget.onCartUpdated(updatedCart); // Update the cart in the parent widget
    showSuccessMessage(context);

    // Navigate to the cart screen after adding the item
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => CartScreen(
          cartItems: updatedCart,
          onCartUpdated: widget.onCartUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.product['image'];
    if (imageUrl.startsWith('https://yourmilktea.com/images/')) {
      imageUrl = imageUrl.replaceFirst('https://yourmilktea.com/images/', '');
    }
    String imageUrlWithBase = 'https://yourmilktea.com/images/$imageUrl';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.product["name"],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Image.network(imageUrlWithBase, width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product["name"],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product["description"],
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "\$${adjustedPrice.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 16),

                  // Size selection
                  Text(
                    "Select Size:",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Row(
                    children: sizePriceChange.keys.map((size) {
                      return CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: selectedSize == size ? CupertinoColors.activeOrange : CupertinoColors.inactiveGray,
                        child: Text(
                          size,
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // Sugar level selection
                  Text(
                    "Select Sugar Level:",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Row(
                    children: sugarLevels.map((level) {
                      return CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        color: selectedSugarLevel == level ? CupertinoColors.activeOrange : CupertinoColors.inactiveGray,
                        child: Text(
                          "$level%",
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedSugarLevel = level;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // Quantity controls
                  Row(
                    children: [
                      CupertinoButton(
                        child: Icon(CupertinoIcons.minus, color: Colors.white),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      CupertinoButton(
                        child: Icon(CupertinoIcons.add, color: Colors.white),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Add to cart button
                  CupertinoButton.filled(
                    child: Text("Add to Cart"),
                    onPressed: () {
                      addToCart(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}