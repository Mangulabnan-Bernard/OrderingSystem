import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../dashboard/dashboard.dart';
import 'about.dart';
import 'detailsproduct.dart';
import 'cart.dart';
import 'home.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<List<Map<String, dynamic>>> onCartUpdated;

  const HomePage({super.key, required this.onCartUpdated});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _categories = [];
  String _selectedCategory = "";
  final String baseUrl = "http://192.168.68.112/devops/images/";
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.68.112/devops/get_products.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories[0]["category"];
          }
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<bool> _verifyAdminPassword(String enteredPassword) async {
    try {
      final response = await http.get(Uri.parse("http://192.168.68.112/devops/userapi.php"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Check if any admin user has the entered password
        for (var user in data) {
          if (user['role'] == 'admin' && user['password'] == enteredPassword) {
            return true;
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      print("Error verifying admin password: $e");
      return false;
    }
  }

  Future<void> _showAdminPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Enter Admin Password"),
        content: CupertinoTextField(
          controller: passwordController,
          obscureText: true,
          placeholder: "Password",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Submit"),
            onPressed: () async {
              final enteredPassword = passwordController.text.trim();
              bool isAdmin = await _verifyAdminPassword(enteredPassword);

              if (isAdmin) {
                setState(() {
                  _isAdmin = true;
                });
                Navigator.pop(context); // Close the dialog
                // Navigate to the DashboardScreen
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => DashboardScreen()),
                );
              } else {
                _showErrorDialog(context); // Show error if wrong password
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Access Denied"),
        content: const Text("Incorrect password. Please try again."),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    widget.onCartUpdated([item]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.power), label: 'Logout'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildHomeScreen();
          case 1:
            return CartScreen(cartItems: [], onCartUpdated: (value) {});
          case 2:
            return AboutPage();
          case 3:
            return _isAdmin ? DashboardScreen() : _requestAdminAccess(context);
          case 4:
            return _handleLogout(context);
          default:
            return const CupertinoPageScaffold(
              child: Center(child: Text("Page not found")),
            );
        }
      },
    );
  }

  Widget _buildHomeScreen() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Home"),
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.black,
          child: Column(
            children: [
              _buildCategoryMenu(),
              Expanded(
                child: _buildProductList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: CupertinoColors.darkBackgroundGray,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map<Widget>((category) {
            bool isSelected = category["category"] == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: isSelected ? CupertinoColors.activeOrange : CupertinoColors.inactiveGray,
                onPressed: () {
                  setState(() {
                    _selectedCategory = category["category"];
                  });
                },
                child: Text(
                  category["category"],
                  style: const TextStyle(color: CupertinoColors.white),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _categories
          .where((category) => category["category"] == _selectedCategory)
          .map<Widget>((category) => _buildCategorySection(category))
          .toList(),
    );
  }

  Widget _buildCategorySection(dynamic category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category["category"],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CupertinoColors.white),
        ),
        const SizedBox(height: 8),
        ...category["products"].map<Widget>((product) => _buildProductItem(product)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductItem(dynamic product) {
    String imageUrl = product['image'].startsWith('http')
        ? product['image']
        : '$baseUrl${product['image']}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => MilkTeaDetailsScreen(
              product: product,
              onCartUpdated: (List<Map<String, dynamic>> value) {},
              cartItems: [],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product["name"], style: const TextStyle(fontSize: 18, color: CupertinoColors.white)),
                  Text("\$${product["price"]}", style: const TextStyle(color: CupertinoColors.activeOrange)),
                  CupertinoButton(child: const Text("Add to Cart"), onPressed: () => _addToCart(product)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestAdminAccess(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton.filled(
          child: const Text("Enter Admin Password"),
          onPressed: () => _showAdminPasswordDialog(context),
        ),
      ),
    );
  }

  Widget _handleLogout(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton.filled(
          child: const Text("Logout"),
          onPressed: () {
            // Perform logout logic here
            // Clear any user session or tokens
            // For example:
            // await clearUserSession();

            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
    );
  }
}
