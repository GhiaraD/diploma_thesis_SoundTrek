import 'package:SoundTrek/pages/BottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication/LoginView.dart';
import 'authentication/RegisterView.dart';
import 'resources/colors.dart' as my_colors;
import 'resources/themes.dart' as my_themes;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  runApp(MaterialApp(home: email == null ? const MyApp() : const NavigationExample()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundTrek',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SoundTrek'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // AssetImage logoAsset = const AssetImage('lib/assets/images/gpt_logo.jpg');
    // Image image = Image(image: logoAsset, width: 500, height: 500);
    return Scaffold(
      backgroundColor: my_colors.Colors.primary,
      appBar: AppBar(
        backgroundColor: my_colors.Colors.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: my_colors.Colors.primary,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: my_colors.Colors.primary,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Expanded(
              flex: 1,
              child: Image(
                fit: BoxFit.contain,
                image: AssetImage('lib/assets/images/logo.png'),
                width: 600,
                height: 600,
              ),
            ),
            // image,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 15),
                    child: TextButton(
                      style: my_themes.Themes.buttonHalfPageStyleLight,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      },
                      child: const Text("Log In"),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 15),
                    child: TextButton(
                      style: my_themes.Themes.buttonHalfPageStyleWhite,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterView()),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
