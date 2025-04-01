import 'package:flutter/cupertino.dart';
import 'home_page.dart'; // HomeScreen widget
import 'cart.dart';
import '../dashboard/dashboard.dart'; // Make sure this import is correct

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart), label: 'Favorites'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomePage(
              onCartUpdated: (items) {
                setState(() {
                  _cartItems = items;
                });
              },
            );
          case 1:
            return DashboardScreen();
          case 2:
            return CartScreen(cartItems: _cartItems, onCartUpdated: (List<Map<String, dynamic>> value) {});
          default:
            return HomePage(
              onCartUpdated: (items) {
                setState(() {
                  _cartItems = items;
                });
              },
            );
        }
      },
    );
  }
}
