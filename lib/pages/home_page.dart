import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../dashboard/dashboard.dart';
import 'detailsproduct.dart';
import 'cart.dart';
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
  final TextEditingController _adminPasswordController = TextEditingController();
  bool _isAdminPasswordCorrect = false;

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
      } else {
        print("Failed to load products, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    widget.onCartUpdated([item]);
  }

  Future<void> _checkAdminPassword(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Admin Password'),
          content: TextField(
            controller: _adminPasswordController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Replace with your actual password check logic
                if (_adminPasswordController.text == 'admin123') {
                  setState(() {
                    _isAdminPasswordCorrect = true;
                  });
                  Navigator.of(context).pop();
                  // Navigate to dashboard if password is correct
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => DashboardScreen()),
                  );
                } else {
                  // Show error if password is incorrect
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Invalid Password'),
                      content: const Text('The admin password is incorrect.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'About'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart), label: 'About'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
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
          case 1:
            return CartScreen(cartItems: [], onCartUpdated: (List<Map<String, dynamic>> value) {});
          case 2:
            return CupertinoPageScaffold(
              child: Center(
                child: const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            );
          case 3:
          // Before accessing dashboard, check for the admin password
            if (!_isAdminPasswordCorrect) {
              _checkAdminPassword(context);
              return const CupertinoPageScaffold(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return DashboardScreen();
          case 4:
            return DashboardScreen();
          default:
            return const CupertinoPageScaffold(
              child: Center(child: Text("Unknown tab")),
            );
        }
      },
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print("Failed to load image: $imageUrl");
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.white),
                  ),
                  Text(
                    product["description"],
                    style: const TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${product["price"]}",
                    style: const TextStyle(fontSize: 16, color: CupertinoColors.activeOrange, fontWeight: FontWeight.bold),
                  ),
                  CupertinoButton(
                    child: const Text("Add to Cart"),
                    onPressed: () {
                      _addToCart(product);
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
