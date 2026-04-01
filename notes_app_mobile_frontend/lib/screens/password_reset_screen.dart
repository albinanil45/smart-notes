import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  const PasswordResetScreen({super.key, required this.email});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _sentOtp();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sentOtp() async {
    try {
      final message = await context.read<AuthProvider>().forgotPassword(
        widget.email,
      );
      AppSnackBar.show(context, message: message ?? "OTP sent to email");
    } catch (e) {
      AppSnackBar.show(context, message: e.toString());
      Navigator.pop(context);
    }
  }

  bool _validateInputs(String otp, String password) {
    if (otp.length != 6) {
      AppSnackBar.show(context, message: "Enter valid 6-digit OTP");
      return false;
    }

    if (password.isEmpty) {
      AppSnackBar.show(context, message: "Password cannot be empty");
      return false;
    }

    if (password.length < 6) {
      AppSnackBar.show(
        context,
        message: "Password must be at least 6 characters",
      );
      return false;
    }

    return true;
  }

  Future<void> _resetPassword(String otp, String newPassword) async {
    if (!_validateInputs(otp, newPassword)) return;

    setState(() => _isLoading = true);

    try {
      final message = await context.read<AuthProvider>().resetPassword(
        email: widget.email,
        otp: otp,
        newPassword: newPassword,
      );

      AppSnackBar.show(
        context,
        message: message ?? "Password reset successful",
      );
      Navigator.pop(context);
    } catch (e) {
      AppSnackBar.show(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpField(int index, ColorScheme colorScheme) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Enter the 6-digit OTP and your new password",
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildOtpField(index, colorScheme),
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          color: colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                String otp = _otpControllers
                                    .map((controller) => controller.text)
                                    .join();

                                String password = _passwordController.text
                                    .trim();

                                await _resetPassword(otp, password);
                              },
                        child: _isLoading
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton.icon(
                        onPressed: _sentOtp,
                        icon: Icon(
                          LucideIcons.refreshCcw,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        label: Text(
                          "Resend OTP",
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
