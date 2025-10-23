import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/authenticate.dart';
import 'package:hidden_gem/pages/home_nav.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/user_service.dart';
import 'package:hidden_gem/utils.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';

class CreateUser extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const CreateUser({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  bool _isEmailVerified = false;
  bool _hasSentEmailVerify = false;

  @override
  void initState() {
    super.initState();

    _buildProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSentEmailVerify && !_isEmailVerified) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "An email has been sent to your inbox.\nPlease verify your email\nand come back to the app.",
              ),
              ElevatedButton(
                onPressed: () async {
                  final verified =
                      await AuthService.checkEmailVerificationStatus();
                  if (!mounted) return;

                  if (!verified) {
                    final snackBar = SnackBar(
                      content: const Text("Email not verified"),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }

                  setState(() {
                    _isEmailVerified = true;
                  });

                  _continueBuilding();
                },
                child: const Text("Check if verified"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Creating account"),
          ],
        ),
      ),
    );
  }

  Future<void> _buildProfile() async {
    final user = await AuthService.signUpUser(widget.email, widget.password);

    if (!mounted) return;

    if (user == null) {
      final snackBar = SnackBar(
        content: const Text("Could not create account"),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _hasSentEmailVerify = true;
      _isEmailVerified = false;
    });

    await AuthService.verifyEmail(user);
  }

  Future<void> _continueBuilding() async {
    final user = FirebaseAuth.instance.currentUser!;

    await user.updateDisplayName(widget.name);

    if (!mounted) return;

    String rawAvatar = Jdenticon.toSvg(widget.name);
    final avatarBytes = await svgToPng(
      rawAvatar,
      context,
      targetWidth: 512,
      targetHeight: 512,
    );
    final file = await uint8ListToFile(avatarBytes, "avatar.png");

    final id = await ImageService.uploadImage(file, "avatars");

    if (id == null) {
      final snackBar = SnackBar(
        content: const Text("Could not create account"),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final url = await ImageService.getImageUrl(id, "avatars");

    await user.updatePhotoURL(url);

    if (!mounted) return;

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser!;
    await UserService.createUserManual(refreshedUser.uid, widget.name, url);

    if (!mounted) return;

    await AuthService.signOut();
    await AuthService.signInUser(widget.email, widget.password);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Authenticate(forward: () => HomeNavigation()),
      ),
      (_) => false,
    );
  }
}
