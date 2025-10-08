import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hidden_gem/pages/auth/authenticate.dart';
import 'package:hidden_gem/pages/auth/forgot_password.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/auth/sign_up.dart';
import 'package:hidden_gem/services/auth_service.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                        Text("Sign in", style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildNormalSignIn(context),
                            _buildDivider(context),
                            _buildGoogleSignIn(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("New to Hidden gems?"),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: Text("Join now"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignIn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: SvgPicture.asset('assets/svgs/Google_G_logo.svg', height: 24),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          await AuthService.signInWithGoogle();
        },
      ),
    );
  }

  Widget _buildNormalSignIn(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            style: _formStyle(),
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
          ),
          SizedBox(height: 20),
          TextFormField(
            style: _formStyle(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Password",
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
            ),
            obscureText: _isPasswordVisible == false,
            enableSuggestions: false,
            autocorrect: false,
            controller: _passwordController,
            validator: (String? text) {
              if (text == null || text.isEmpty) {
                return "Please enter your password";
              }

              return null;
            },
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPassword()),
              );
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text("Forgot password?"),
          ),

          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder()),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                await AuthService.signInUser(
                  _emailController.text,
                  _passwordController.text,
                );

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Authenticate(forward: () => HomePage()),
                  ),
                  (_) => false,
                );
              },
              child: const Text("Sign in"),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _formStyle() {
    return TextStyle(fontSize: 14);
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1.0,
              thickness: 0.2,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "or",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1.0,
              thickness: 0.2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
