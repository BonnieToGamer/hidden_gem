import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/create_post.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/own_user_profile.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomNavigationBar({super.key, required this.currentIndex});

  void _move(BuildContext context, Widget newWidget) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => newWidget,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 40,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: currentIndex,
      onDestinationSelected: (int index) {
        if (index == 0) {
          _move(context, HomePage());
        } else if (index == 1) {
          _move(context, CreatePost());
        } else if (index == 2) {
          _move(context, OwnUserProfile());
        }
      },

      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "home",
        ),
        NavigationDestination(
          icon: Icon(Icons.add_outlined),
          selectedIcon: Icon(Icons.add),
          label: "add post",
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "profile",
        ),
      ],
    );
  }
}
