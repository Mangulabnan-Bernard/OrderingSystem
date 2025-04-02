import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  theme: CupertinoThemeData(
    brightness: Brightness.dark, // Enable dark mode globally
  ),
  home: Users(),
));

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String server = "http://192.168.68.112";
  List<dynamic> users = [];

  Future<void> getData() async {
    try {
      final response = await http.get(Uri.parse("$server/devops/userAPI.php"));
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Error"),
            content: Text("Failed to fetch users. Please try again."),
            actions: [
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
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

  Future<void> updateUser(String id, String password) async {
    try {
      await http.post(
        Uri.parse("$server/devops/update.php"),
        body: {"id": id, "password": password},
      );
      getData();
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Failed to update user: $e"),
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

  Future<void> deleteUser(String id) async {
    try {
      await http.post(
        Uri.parse("$server/devops/delete.php"),
        body: {"id": id},
      );
      getData();
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Failed to delete user: $e"),
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

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black, // Dark background
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Users",
          style: TextStyle(color: CupertinoColors.white, fontSize: 20),
        ),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CupertinoColors.black, // Dark navbar
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final item = users[index];
            bool isAdmin = item['username'] == "admin"; // Check if the user is admin

            return CupertinoListTile(
              title: Text(
                item['username'],
                style: TextStyle(color: CupertinoColors.white, fontSize: 18),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAdmin) ...[
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.pencil,
                        color: CupertinoColors.systemBlue,
                      ),
                      onPressed: () {
                        TextEditingController _passwordController =
                        TextEditingController(text: item['password']);
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text("Change Password"),
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CupertinoTextField(
                                controller: _passwordController,
                                placeholder: "New Password",
                                obscureText: true,
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: Text("Cancel", style: TextStyle(color: CupertinoColors.systemGrey)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                child: Text("Save", style: TextStyle(color: CupertinoColors.systemBlue)),
                                onPressed: () {
                                  updateUser(item['id'], _passwordController.text);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (!isAdmin) ...[
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.trash_fill,
                        color: CupertinoColors.destructiveRed,
                      ),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text("Delete User"),
                            content: Text("Are you sure you want to delete ${item['username']}?"),
                            actions: [
                              CupertinoDialogAction(
                                child: Text("Cancel", style: TextStyle(color: CupertinoColors.systemGrey)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
                                onPressed: () {
                                  deleteUser(item['id']);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}