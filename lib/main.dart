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
  
  
