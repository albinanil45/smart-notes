import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notes_app_mobile_frontend/providers/auth_provider.dart';
import 'package:notes_app_mobile_frontend/screens/otp_verification_screen.dart';
import 'package:notes_app_mobile_frontend/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

class NotVerifiedScreen extends StatefulWidget {
  final String email;

  const NotVerifiedScreen({super.key, required this.email});

  @override
  State<NotVerifiedScreen> createState() => _NotVerifiedScreenState();
}

class _NotVerifiedScreenState extends State<NotVerifiedScreen> {
  bool isSending = false;

  Future<void> handleSendOtp() async {
    setState(() => isSending = true);

    try {
      final message = await context.read<AuthProvider>().resendOtp();
      AppSnackBar.show(context, message: message ?? "OTP sent successfully");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: widget.email),
        ),
      );
    } catch (e) {
      AppSnackBar.show(context, message: e.toString());
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.mailX,
                    size: 50,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  "Verify Your Email",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  "Your email address is not verified yet.\n"
                  "We will send a one-time password (OTP) to:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Email Highlight
                Text(
                  widget.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSending ? null : handleSendOtp,
                    icon: isSending
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Icon(LucideIcons.send),
                    label: Text(isSending ? "Sending..." : "Send OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Back button
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                  },
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: colors.primary,
                  ),
                  label: Text(
                    "Back to Login",
                    style: TextStyle(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
