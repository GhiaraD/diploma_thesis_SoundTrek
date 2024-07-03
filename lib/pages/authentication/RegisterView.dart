import 'package:SoundTrek/pages/BottomNavigation.dart';
import 'package:SoundTrek/resources/colors.dart' as my_colors;
import 'package:SoundTrek/resources/themes.dart' as my_themes;
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'LoginView.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthenticationService apiService = AuthenticationService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isObscuredPassword = true;
  bool _isObscuredConfirmPassword = true;

  Future<bool> _register() async {
    try {
      await apiService.register(
        _usernameController.text,
        _passwordController.text,
        _emailController.text,
      );
      print('User registered');
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscuredPassword = !_isObscuredPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isObscuredConfirmPassword = !_isObscuredConfirmPassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: my_colors.Colors.greyBackground,
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: my_colors.Colors.greyBackground,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: my_colors.Colors.greyBackground,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: my_colors.Colors.greyBackground,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              cursorColor: my_colors.Colors.primary,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                floatingLabelStyle: TextStyle(color: my_colors.Colors.primary, fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: my_colors.Colors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              cursorColor: my_colors.Colors.primary,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                floatingLabelStyle: TextStyle(color: my_colors.Colors.primary, fontWeight: FontWeight.bold),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: my_colors.Colors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _isObscuredPassword ? true : false,
              cursorColor: my_colors.Colors.primary,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                floatingLabelStyle: const TextStyle(color: my_colors.Colors.primary, fontWeight: FontWeight.bold),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: my_colors.Colors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isObscuredPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isObscuredConfirmPassword ? true : false,
              cursorColor: my_colors.Colors.primary,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                floatingLabelStyle: const TextStyle(color: my_colors.Colors.primary, fontWeight: FontWeight.bold),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: my_colors.Colors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isObscuredConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "By clicking Sign Up, you are agreeing to APP's Terms of service, "
              "are acknowledging our Privacy Notice and the EEA/UK Right of Withdrawal Notice.",
              textAlign: TextAlign.left,
              style: TextStyle(color: my_colors.Colors.greyDark, fontSize: 10),
            ),
            const SizedBox(height: 5),
            TextButton(
              style: _isButtonEnabled
                  ? (my_themes.Themes.buttonHalfPageStyle)
                  : (my_themes.Themes.buttonHalfPageStyleDisabled),
              onPressed: _isButtonEnabled
                  ? () async {
                      bool registered = await _register();
                      if (registered) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const NavigationExample()),
                          ModalRoute.withName('/'),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration failed. Please try again.'),
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Sign Up'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  Text("Log In.", style: TextStyle(color: my_colors.Colors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
