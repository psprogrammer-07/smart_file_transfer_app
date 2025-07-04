import 'package:flutter/material.dart';
import 'package:phone_to_sd/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

Widget sidebar(BuildContext context,Function(bool) toggleTheme){
  final p_url = "https://sites.google.com/view/transfergenie-privacy-policy-/home";

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      throw 'Could not launch $url';
    }
  }

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(''),
          accountEmail: Text(''),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsScreen(toggleTheme: toggleTheme,),));
          },
        ),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Privacy Policy'),
          onTap: () => _launchURL(p_url),
        ),


        ListTile(
          leading: Icon(Icons.help),
          title: Text('Help/Support'),
          onTap: () {
           _sendEmail("thedeveloper21e@gmail.com");
          },
        ),
      ],
    ),
  );
}
Future<void> _sendEmail(String emailId) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: emailId,
  );

  if (true) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch $emailUri';
  }
}
