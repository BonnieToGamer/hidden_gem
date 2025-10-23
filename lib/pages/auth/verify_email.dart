import 'package:flutter/material.dart';
import 'package:hidden_gem/services/auth_service.dart';

class VerifyEmail extends StatefulWidget {
  final VoidCallback onVerified;

  const VerifyEmail({super.key, required this.onVerified});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool _checking = false;

  Future<void> _checkVerification() async {
    setState(() => _checking = true);

    final verified = await AuthService.checkEmailVerificationStatus();

    if (!mounted) return;

    if (verified) {
      widget.onVerified();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not verified")));
    }

    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "An email has been sent to your inbox.\n"
              "Please verify your email and come back to the app.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checking ? null : _checkVerification,
              child: const Text("Check if verified"),
            ),
          ],
        ),
      ),
    );
  }
}
