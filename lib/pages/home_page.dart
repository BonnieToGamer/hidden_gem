import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/sign_in_screen.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/google_auth_service.dart';
import 'package:hidden_gem/widgets/gems_map.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';

class HomePage extends StatelessWidget {
  final GoogleAuthService _authService = GoogleAuthService();
  final User user;

  HomePage({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _checkPermission(),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0, user: user),
    );
  }

  Widget _homePage() {
    return GemsMap();
  }

  FutureBuilder<bool> _checkPermission() {
    return FutureBuilder(
      future: GeolocatorService.checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("There was an error")
          );
        }

        bool hasPermission = snapshot.data!;

        if (!hasPermission) {
          return const Center(
            child: Text("Permission denied")
          );
        }

        return _homePage();
      }
    );
  }
}