import 'package:flutter/cupertino.dart';
import 'users.dart';
import 'inventory.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black, // Set background color to black for dark mode
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Dashboard",
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: CupertinoColors.black, // Dark mode navbar
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // Add padding for better spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons to full width
            children: [
              // Title Text
              Text(
                "Welcome, Admin!",
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Manage your users and inventory efficiently.",
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40), // Add spacing between title and buttons

              // Users Button
              CupertinoButton(
                color: CupertinoColors.activeBlue, // Use a bright accent color
                borderRadius: BorderRadius.circular(10), // Rounded corners for buttons
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15), // Increase button height
                  child: Text(
                    "Users",
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
                    CupertinoPageRoute(builder: (context) => Users()),
                  );
                },
              ),
              SizedBox(height: 20), // Add spacing between buttons

              // Inventory Button
              CupertinoButton(
                color: CupertinoColors.systemPurple, // Use another accent color
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    "Inventory",
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
                    CupertinoPageRoute(builder: (context) => InventoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}