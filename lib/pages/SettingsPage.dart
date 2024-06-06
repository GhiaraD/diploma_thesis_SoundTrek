import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../resources/colors.dart' as my_colors;
import '../../resources/themes.dart' as my_themes;
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthenticationService apiService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: my_colors.Colors.greyBackground,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: my_colors.Colors.greyBackground,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: my_colors.Colors.greyBackground,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: my_colors.Colors.greyBackground,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account'),
            subtitle: const Text('Profile, Password'),
            onTap: () {
              // Handle security and privacy tap
            },
          ),
          ListTile(
            title: const Text('Calibrate'),
            onTap: () {
              // Handle security and privacy tap
            },
          ),
          ListTile(
            title: const Text('Contact us'),
            onTap: () {
              // Handle notifications tap
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () {
              // Handle terms of service tap
            },
          ),
          ListTile(
            title: const Text('Privacy Notice'),
            onTap: () {
              // Handle privacy notice tap
            },
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'SoundTrek v0.1.0 (c)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const Center(
            child: Text(
              'July 01, 2024 at 11:15 AM',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () async {
                apiService.logout();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const MyHomePage(title: "SoundTrek")));
              },
              style: my_themes.Themes.buttonHalfPageStyleDisabled,
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}
