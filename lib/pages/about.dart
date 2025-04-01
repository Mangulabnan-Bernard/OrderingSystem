import 'package:flutter/cupertino.dart';
import '../dashboard/dashboard.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<Map<String, dynamic>> members = [
    {"name": "Bernard Mangulabnan", "role": "Lead Developer", "icon": CupertinoIcons.star, "color": CupertinoColors.systemBlue},
    {"name": "Mervin Magat", "role": "Developer/UI Designer", "icon": CupertinoIcons.paintbrush, "color": CupertinoColors.systemGreen},
    {"name": "Steven Lising", "role": "Backend Developer", "icon": CupertinoIcons.gear, "color": CupertinoColors.systemOrange},
    {"name": "Paul Vismonte", "role": "Tester/Testing", "icon": CupertinoIcons.checkmark_seal, "color": CupertinoColors.systemPurple},
    {"name": "Renz Samson", "role": "Content Writer/Accessibility Tester", "icon": CupertinoIcons.doc_text, "color": CupertinoColors.systemRed},
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('We are the Developers'),
        backgroundColor: CupertinoColors.systemBlue,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Meet the Team',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CupertinoColors.black),
              ),
            ),
            Expanded(
              child: CupertinoListSection.insetGrouped(
                children: members.map((member) {
                  return CupertinoListTile(
                    leading: Icon(member['icon'], color: member['color']),
                    title: member['name'] == "Bernard Mangulabnan"
                        ? GestureDetector(
                      onTap: () {
                        // Navigate to the DashboardScreen when Bernard's name is clicked
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => DashboardScreen()),
                        );
                      },
                      child: Text(
                        member['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white), // Make the name blue to indicate it's clickable
                      ),
                    )
                        : Text(
                      member['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(member['role']),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
