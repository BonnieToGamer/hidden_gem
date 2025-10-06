import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                child: SizedBox(
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Forgot password", style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmailForm(),
              SizedBox(height: 20),
              _buildSendButton(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Back"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextFormField _buildEmailForm() {
    return TextFormField(
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Email",
      ),
      controller: _emailController,
      validator: (String? text) {
        if (text == null || text.isEmpty) {
          return "Please enter your email";
        }

        if (EmailValidator.validate(text) == false) {
          return "Please enter a valid email";
        }

        return null;
      },
    );
  }

  SizedBox _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(shape: RoundedRectangleBorder()),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          try {
            await AuthService.forgotPassword(_emailController.text);
          } catch (err) {
            if (!mounted) return;
            const snackBar = SnackBar(
              content: Text("Something went wrong sending the email!"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }

          Navigator.pop(context);
          const snackBar = SnackBar(
            content: Text("Password reset email sent!"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: const Text("Sign in"),
      ),
    );
  }
}
