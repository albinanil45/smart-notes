// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/screens/otp_verification_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

class RegisterWidget extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterWidget({super.key, required this.onLoginTap});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

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
                "Create your account",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// Description
              Text(
                "Capture ideas, organize your thoughts, and stay productive with ease.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              /// Name
              TextFormField(
                controller: nameController,
                decoration: buildInput("Name", LucideIcons.user),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              /// Confirm Password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: buildInput(
                  "Confirm Password",
                  LucideIcons.lock,
                  suffix: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? LucideIcons.eyeOff
                          : LucideIcons.eye,
                      color: colors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// Register Button
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
                        final message = await auth.register(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                        AppSnackBar.show(context, message: message ?? "");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OtpVerificationScreen(
                              email: emailController.text,
                            ),
                          ),
                        );
                      } catch (e) {
                        AppSnackBar.show(context, message: e.toString());
                      }
                    }
                  },
                  child: const Text("Create Account"),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔁 Login Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onLoginTap,
                    child: Text(
                      "Login",
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
