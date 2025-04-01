import 'package:flutter/cupertino.dart';

void main()=>runApp(CupertinoApp(
  debugShowCheckedModeBanner: false,
  home: Homepage(), ));

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: SafeArea(child: Column(
      children: [
        Text('test')
      ],
    )));
  }
}
