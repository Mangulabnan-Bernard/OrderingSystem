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
          print("Raw server response: ${response.body}"); // Debug log
          final Map<String, dynamic> responseData = json.decode(response.body);

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

          if (responseData['success'] == true) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => HomePage(onCartUpdated: (List<Map<String, dynamic>> value) {}),
              ),
            );
          } else {
            _showErrorDialog("Account Creation Failed", responseData['message'] ?? "Error creating account.");
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Welcome"),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoginVisible) ...[
                CupertinoButton(
                  child: Text("Sign In"),
                  onPressed: () {
                    setState(() {
                      _isLoginVisible = true;
                    });
                  },
                ),
              ],
              if (_isLoginVisible) ...[
                Text(
                  _isCreateAccount ? "Create Account" : "Login",
                  style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                ),
                SizedBox(height: 20),
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: _isCreateAccount ? "Create Username" : "Username",
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: _isCreateAccount ? "Create Password" : "Password",
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CupertinoActivityIndicator()
                    : CupertinoButton.filled(
                  child: Text(_isCreateAccount ? "Create Account" : "Login"),
                  onPressed: _isCreateAccount ? _createAccount : _login,
                ),
                if (!_isCreateAccount) ...[
                  CupertinoButton(
                    child: Text("Create Account"),
                    onPressed: () {
                      setState(() {
                        _isCreateAccount = true;
                      });
                    },
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