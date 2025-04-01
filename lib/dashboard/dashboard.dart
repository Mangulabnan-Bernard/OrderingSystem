import 'package:flutter/cupertino.dart';
import 'users.dart';
import 'inventory.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Dashboard", style: TextStyle(color: CupertinoColors.white)),
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton.filled(
              child: Text("Users"),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => Users()),
                );
              },
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text("Inventory"),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => InventoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
