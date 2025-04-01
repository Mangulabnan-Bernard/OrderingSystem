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
  
  
