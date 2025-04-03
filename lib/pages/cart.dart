import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final ValueChanged<List<Map<String, dynamic>>> onCartUpdated;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCartUpdated,
  });

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double getTotalPrice() {
    double total = 0;
    for (var item in widget.cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void clearCart(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Clear Cart"),
        content: Text("Are you sure you want to clear your cart?"),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text("Yes"),
            onPressed: () {
              Navigator.pop(context);
              widget.onCartUpdated([]); // Clear the cart
            },
          ),
        ],
      ),
    );
  }

  Future<void> checkout(BuildContext context) async {
    String? selectedPayment = await showPaymentOptions(context);

    if (selectedPayment == null) {
      return; // User canceled payment selection
    }

    // Calculate total quantity and price for the summary
    int totalQuantity = widget.cartItems.fold<int>(
      0,
          (sum, item) => sum + (item['quantity'] as num).toInt(),
    );
    double totalPrice = getTotalPrice();

    // Show order summary dialog
    bool? shouldProceed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Order Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Total Items: $totalQuantity"),
            Text("Total Price: \$${totalPrice.toStringAsFixed(2)}"),
            Text("Payment Method: $selectedPayment"),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false), // Cancel checkout
          ),
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context, true), // Proceed with checkout
          ),
        ],
      ),
    );

    // If the user cancels, stop the checkout process
    if (shouldProceed != true) {
      return;
    }

    // Proceed with the checkout process
    final url = Uri.parse('https://yourmilkteashop.com/checkout.php');
    try {
      for (var item in widget.cartItems) {
        final response = await http.post(url, body: {
          'product_id': item["id"].toString(),
          'quantity': item["quantity"].toString(),
        });

        if (response.statusCode != 200) {
          throw Exception("Failed to place order");
        }

        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] != "success") {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text("Error"),
              content: Text(jsonResponse["message"]),
              actions: [
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
      }

      // Show success dialog after successful checkout
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Success"),
          content: Text("Order placed successfully!"),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
                widget.onCartUpdated([]); // Clear the cart
              },
            ),
          ],
        ),
      );
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

  Future<String?> showPaymentOptions(BuildContext context) async {
    return await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text("Select Payment Method"),
        actions: [
          CupertinoActionSheetAction(
            child: Text("Gcash"),
            onPressed: () => Navigator.pop(context, "Gcash"),
          ),
          CupertinoActionSheetAction(
            child: Text("Credit Card"),
            onPressed: () => Navigator.pop(context, "Credit Card"),
          ),
          CupertinoActionSheetAction(
            child: Text("PayPal"),
            onPressed: () => Navigator.pop(context, "PayPal"),
          ),
          CupertinoActionSheetAction(
            child: Text("Bank Transfer"),
            onPressed: () => Navigator.pop(context, "Bank Transfer"),
          ),
          CupertinoActionSheetAction(
            child: Text("Apple Pay"),
            onPressed: () => Navigator.pop(context, "Apple Pay"),
          ),
          CupertinoActionSheetAction(
            child: Text("Google Pay"),
            onPressed: () => Navigator.pop(context, "Google Pay"),
          ),
          CupertinoActionSheetAction(
            child: Text("Cash on Delivery"),
            onPressed: () => Navigator.pop(context, "Cash on Delivery"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Your Cart",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(
            "Clear",
            style: TextStyle(color: Colors.orange),
          ),
          onPressed: () => clearCart(context),
        ),
      ),
      child: SafeArea(
        child: widget.cartItems.isEmpty
            ? Center(
          child: Text(
            "Your cart is empty.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  var item = widget.cartItems[index];
                  String imageUrl = item['image'];
                  if (imageUrl.startsWith('https://yourmilkteashop.com/images/')) {
                    imageUrl = imageUrl.replaceFirst('https://yourmilkteashop.com/images/', '');
                  }
                  String imageUrlWithBase = imageUrl.startsWith('http')
                      ? imageUrl
                      : 'https://yourmilkteashop.com/images/$imageUrl';


                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(imageUrlWithBase),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                "Size: ${item['size']} - Sugar: ${item['sugarLevel']}%",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              Text(
                                "\$${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.delete),
                          onPressed: () {
                            setState(() {
                              widget.cartItems.removeAt(index);
                              widget.onCartUpdated(widget.cartItems);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: \$${getTotalPrice().toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  CupertinoButton(
                    color: Colors.orange,
                    child: Text("Checkout"),
                    onPressed: () => checkout(context),
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