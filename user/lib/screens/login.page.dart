import 'package:flutter/material.dart';
import '../utils/auth.service.dart';
import '../utils/global.colors.dart';
import 'signup.page.dart';

class LoginScreen extends StatefulWidget {
  final Function? onLoginSuccess;
  const LoginScreen({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoggingIn = false;
  bool _showAccountNotFoundMessage = false;
  bool _showWrongPasswordMessage = false;

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/bottomNavbar');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Wellness',
                  style: TextStyle(
                    color: GlobalColors.TextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: GlobalColors.TextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      setState(() {
                        _isLoggingIn = true;
                        _showAccountNotFoundMessage = false;
                        _showWrongPasswordMessage = false;
                      });

                      final user = await _authService.signInWithEmailAndPassword(email, password);
                      if (user != null) {
                        setState(() {
                          _isLoggingIn = false;
                        });
                        Navigator.pushReplacementNamed(context, '/bottomNavbar');
                      } else {
                        setState(() {
                          _isLoggingIn = false;
                          if (_authService.accountExists(email)) {
                            _showWrongPasswordMessage = true;
                          } else {
                            _showAccountNotFoundMessage = true;
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                    ),
                    child: _isLoggingIn
                        ? CircularProgressIndicator()
                        : Text(
                      'Login',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                if (_showAccountNotFoundMessage)
                  const Text(
                    'Account not found. Please sign up first in order to log in.',
                    style: TextStyle(color: Colors.red),
                  ),
                if (_showWrongPasswordMessage)
                  const Text(
                    'Wrong password. Please enter the correct password.',
                    style: TextStyle(color: Colors.red),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
