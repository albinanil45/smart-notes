import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/screens/password_reset_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatefulWidget {
  final VoidCallback onRegisterTap;

  const LoginWidget({super.key, required this.onRegisterTap});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    InputDecoration buildInput(String label, IconData icon, {Widget? suffix}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary),
        suffixIcon: suffix,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔷 App Title + Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.stickyNote, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Smart Notes",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Title
              Text(
                "Welcome back 👋",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtitle
              Text(
                "Login to continue capturing and organizing your ideas.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              /// Email
              TextFormField(
                controller: emailController,
                decoration: buildInput("Email", LucideIcons.mail),
              ),

              const SizedBox(height: 16),

              /// Password
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: buildInput(
                  "Password",
                  LucideIcons.lock,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: colors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Forgot Password (optional)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      AppSnackBar.show(
                        context,
                        message: "Please enter your email first",
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordResetScreen(email: email),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final message = await auth.login(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        AppSnackBar.show(context, message: message ?? "");
                      } catch (e) {
                        AppSnackBar.show(context, message: e.toString());
                      }
                    }
                  },
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔁 Register Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onRegisterTap,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
