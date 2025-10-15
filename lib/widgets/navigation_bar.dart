import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/post/create_post.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/user_profile/own_user_profile.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTapCallback;

  const CustomNavigationBar(
      {super.key, required this.currentIndex, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 40,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: currentIndex,
      onDestinationSelected: onTapCallback,

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
