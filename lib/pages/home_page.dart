import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../dashboard/dashboard.dart';
import 'about.dart';
import 'detailsproduct.dart';
import 'cart.dart';
import 'home.dart';

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
  String _adminErrorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final response = await http.get(
          Uri.parse("http://192.168.68.112/devops/get_products.php"));
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

  void _handleAdminPassword(String enteredPassword) {
    if (enteredPassword == 'test123') { // Updated password to 'test123'
      setState(() {
        _isAdmin = true;
        _adminErrorMessage = "";
      });
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      setState(() {
        _adminErrorMessage = "Incorrect password. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          // BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.info), label: 'About'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.power), label: 'Logout'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _buildHomeScreen();
          case 1:
            return AboutPage();
          case 2:
            return _isAdmin ? DashboardScreen() : _requestAdminAccess(context);
          case 3:
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
                color: isSelected
                    ? CupertinoColors.activeOrange
                    : CupertinoColors.inactiveGray,
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
          style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
        const SizedBox(height: 8),
        ...category["products"].map<Widget>((product) =>
            _buildProductItem(product)).toList(),
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
            builder: (context) =>
                MilkTeaDetailsScreen(
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
                  Text(product["name"], style: const TextStyle(
                      fontSize: 18, color: CupertinoColors.white)),
                  const SizedBox(height: 4),
                  Text(product["description"], style: const TextStyle(
                      fontSize: 14, color: CupertinoColors.inactiveGray)),
                  const SizedBox(height: 4),
                  Text("\$${product["price"]}", style: const TextStyle(
                      color: CupertinoColors.activeOrange)),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    child: const Text("Buy Now"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              MilkTeaDetailsScreen(
                                product: product,
                                onCartUpdated: (
                                    List<Map<String, dynamic>> value) {},
                                cartItems: [],
                              ),
                        ),
                      );
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

  Widget _requestAdminAccess(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Message at the top
            Text(
              "This is restricted Area. Please put admin password to access",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Password input field
            CupertinoTextField(
              controller: passwordController,
              obscureText: true,
              placeholder: "Enter Admin Password",
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Access Granted button
            CupertinoButton(
              color: CupertinoColors.systemGrey3,
              child: const Text("Access Granted"),
              onPressed: () {
                _handleAdminPassword(passwordController.text.trim());
              },
            ),
            const SizedBox(height: 16),

            // Error message (if any)
            if (_adminErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _adminErrorMessage,
                  style: const TextStyle(color: CupertinoColors.destructiveRed),
                ),
              ),
          ],
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
            // Show confirmation dialog
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('Yes'),
                      onPressed: () {
                        // Remove all previous routes and go to LoginScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => LoginScreen()),
                              (Route<
                              dynamic> route) => false, // Remove all previous routes
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}