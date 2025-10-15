import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/post/create_post.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/user_profile/own_user_profile.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTapCallback;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      onTap: onTapCallback,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "home"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_outlined),
            activeIcon: Icon(Icons.add),
            label: "post"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "profile"
        ),
      ],
    );
  }
}
