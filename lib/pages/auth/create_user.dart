import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/authenticate.dart';
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
  @override
  void initState() {
    super.initState();

    buildProfile();
  }

  @override
  Widget build(BuildContext context) {
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

  Future<void> buildProfile() async {
    final user = await AuthService.signUpUser(widget.email, widget.password);

    if (!mounted) return;

    if (user == null) {
      final snackBar = SnackBar(
          content: const Text("Could not create account")
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

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
          content: const Text("Could not create account")
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

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => Authenticate(forward: () => HomePage())), (
        _) => false);
  }
}
