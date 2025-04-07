import 'package:flutter/material.dart';

import '../entities/user.entity.dart';
import '../screens/login.page.dart';
import 'auth.service.dart';
import 'bottom.nav.bar.dart';

class AuthenticationWrapper extends StatelessWidget {
  final Widget child;
  final AuthService _authService = AuthService();

  AuthenticationWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: CircularProgressIndicator());
        } else {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          } else {
            return MyBottomNavigationBar(currentUser:user);
          }
        }
      },
    );
  }
}
