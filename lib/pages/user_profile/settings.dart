import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/auth/sign_in.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ?_locationPermissionButton(),

            ElevatedButton(
              onPressed: () async {
                await AuthService.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SignIn()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade900,
              ),
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _locationPermissionButton() {
    if (GeolocatorService.hasLocationPermission) {
      return null;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "You don't seem to have location permissions enabled, please enable them for the best experience",
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: () async {
            bool result = await GeolocatorService.checkPermission();

            if (result == false) {
              GeolocatorService.openSettings();
            }

            setState(() {}); // update button
          },
          child: Text("Open Location settings"),
        ),
      ],
    );
  }
}
