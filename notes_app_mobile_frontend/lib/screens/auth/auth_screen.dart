import 'package:flutter/material.dart';
import 'login_widget.dart';
import 'register_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleAuth() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: isLogin
            ? LoginWidget(
                key: const ValueKey("login"),
                onRegisterTap: toggleAuth,
              )
            : RegisterWidget(
                key: const ValueKey("register"),
                onLoginTap: toggleAuth,
              ),
      ),
    );
  }
}
