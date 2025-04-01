import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginVisible = false; // Toggle between login and create account form
  bool _isCreateAccount = false; // Track if we are creating a new account

  // Function to handle login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        throw Exception("Please enter both username and password.");
      }

      // Call the login API
      final response = await http.post(
        Uri.parse('http://192.168.68.112/devops/login.php'),
        body: {
          'username': username,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("The request timed out.");
      });

      print("Raw server response: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('success')) {
            if (responseData['success'] == true) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => HomePage(onCartUpdated: (List<Map<String, dynamic>> value) {}),
                ),
              );
            } else {
              _showErrorDialog("Login Failed", responseData['message'] ?? "Invalid credentials.");
            }
          } else {
            _showErrorDialog("Error", "Unexpected server response.");
          }
        } catch (e) {
          print("Error parsing response: $e"); // Debug log
          _showErrorDialog("Error", "Failed to parse server response.");
        }
      } else {
        _showErrorDialog("Error", "Failed to connect to the server.");
      }
    } catch (e) {
      _showErrorDialog("Error", e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle account creation
  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        throw Exception("Please enter both username and password.");
      }

      // Call the create account API
      final response = await http.post(
        Uri.parse('http://192.168.68.112/devops/signup.php'),
        body: {
          'username': username,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("The request timed out.");
      });

      print("Raw server response: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData.containsKey('success')) {
            if (responseData['success'] == true) {
              // Go back to the login screen after account creation
              setState(() {
                _isCreateAccount = false; // Show login screen
              });
              _usernameController.clear();
              _passwordController.clear();
            } else {
              _showErrorDialog("Account Creation Failed", responseData['message'] ?? "Error creating account.");
            }
          } else {
            _showErrorDialog("Error", "Unexpected server response.");
          }
        } catch (e) {
          print("Error parsing response: $e"); // Debug log
          _showErrorDialog("Error", "Failed to parse server response.");
        }
      } else {
        _showErrorDialog("Error", "Failed to connect to the server.");
      }
    } catch (e) {
      _showErrorDialog("Error", e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show error dialogs
  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Logout"),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Welcome to Shop"),
        backgroundColor: CupertinoColors.black,
      ),
      backgroundColor: CupertinoColors.black,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoginVisible) ...[
                CupertinoButton(
                  child: Text("Sign In", style: TextStyle(color: CupertinoColors.white)),
                  onPressed: () {
                    setState(() {
                      _isLoginVisible = true;
                    });
                  },
                  color: CupertinoColors.activeBlue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  borderRadius: BorderRadius.circular(15),
                ),
              ],
              if (_isLoginVisible) ...[
                Text(
                  _isCreateAccount ? "Create Account" : "Login",
                  style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(height: 20),
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: _isCreateAccount ? "Create Username" : "Username",
                  keyboardType: TextInputType.text,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  style: TextStyle(color: CupertinoColors.white),
                ),
                SizedBox(height: 20),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: _isCreateAccount ? "Create Password" : "Password",
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  style: TextStyle(color: CupertinoColors.white),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CupertinoActivityIndicator(color: CupertinoColors.white)
                    : CupertinoButton.filled(
                  child: Text(_isCreateAccount ? "Create Account" : "Login"),
                  onPressed: _isCreateAccount ? _createAccount : _login,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  borderRadius: BorderRadius.circular(15),
                ),
                if (_isCreateAccount) ...[
                  CupertinoButton(
                    child: Text("Cancel", style: TextStyle(color: CupertinoColors.white)),
                    onPressed: () {
                      setState(() {
                        _isCreateAccount = false;
                      });
                    },
                    color: CupertinoColors.destructiveRed,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ],
                if (!_isCreateAccount) ...[
                  CupertinoButton(
                    child: Text("Create Account", style: TextStyle(color: CupertinoColors.white)),
                    onPressed: () {
                      setState(() {
                        _isCreateAccount = true;
                      });
                    },
                    color: CupertinoColors.activeGreen,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
