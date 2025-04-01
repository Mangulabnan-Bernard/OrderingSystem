import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Users(),
));

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String server = "http://192.168.68.112";
  List<dynamic> user = [];

  Future<void> getData() async {
    final response = await http.get(Uri.parse(server + "/devops/userAPI.php"));
    setState(() {
      user = jsonDecode(response.body);
    });
  }
  Future<void> updateUser(String id, String password) async {
    await http.post(
      Uri.parse(server + "/devops/update.php"),
      body: {"id": id, "password": password},
    );
    getData();
  }

  Future<void> deleteUser(String id) async {
    await http.post(
      Uri.parse(server + "/devops/delete.php"),
      body: {"id": id},
    );
    getData();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Users"),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: user.length,
          itemBuilder: (context, index) {
            final item = user[index];
            TextEditingController _password =
            TextEditingController(text: item['password']);
                  return CupertinoListTile(
              title: Text(item['username']),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Icon(CupertinoIcons.trash_fill, color: CupertinoColors.destructiveRed),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('Delete User'),
                            content: Text('Are you sure you want to delete ${item['username']}?'),
                            actions: [
                              CupertinoButton(
                                child: Text("Cancel", style: TextStyle(color: CupertinoColors.systemGrey)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoButton(
                                child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
                                onPressed: () {
                                  deleteUser(item['id']);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                        
                  CupertinoButton(
                    child: Icon(CupertinoIcons.pencil, color: CupertinoColors.systemBlue),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('Change Password for ${item['username']}'),
                            content: CupertinoTextField(
                              controller: _password,
                            ),
                            actions: [
                              CupertinoButton(
                                child: Text("Close", style: TextStyle(color: CupertinoColors.destructiveRed)),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoButton(
                                child: Text("Save", style: TextStyle(color: CupertinoColors.systemBlue)),
                                onPressed: () {
                                  updateUser(item['id'], _password.text);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
  
  
