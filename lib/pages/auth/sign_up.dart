import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hidden_gem/pages/auth/create_user.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/auth/sign_in.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/user_service.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
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
                        Text("Sign up", style: TextStyle(fontSize: 24)),
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
                  Text("Already have an account?"),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: Text("Sign in"),
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
          'Sign up with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          final user = await AuthService.signInWithGoogle();
          if (user != null) {
            await UserService.createUser(user);
          }
        },
      ),
    );
  }

  Widget _buildNormalSignIn(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            style: _formStyle(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Name",
            ),
            controller: _nameController,
            validator: (String? text) {
              if (text == null || text.isEmpty) {
                return "Please enter your name";
              }

              if (text.length < 3) {
                return "Name must be longer than 3 characters";
              }

              return null;
            },
          ),
          SizedBox(height: 20),
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

              // regex taken from: https://regexpattern.com/strong-password/
              if (!RegExp(
                r'^\S*(?=\S{6,})(?=\S*\d)(?=\S*[A-Z])(?=\S*[a-z])(?=\S*[!@#$%^&*? ])\S*$',
              ).hasMatch(text)) {
                return """
Password must be:
 - Minimum 6 characters
 - At least 1 upper case English letter
 - At least 1 lower case English letter
 - At least 1 letter
 - At least 1 special character""";
              }

              return null;
            },
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

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateUser(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      continueBuilding: false,
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Sign up"),
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
