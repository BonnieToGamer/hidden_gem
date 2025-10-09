import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/post/create_post.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/user_profile/own_user_profile.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;

  static final PageStorageBucket _bucket = PageStorageBucket();

  static final HomePage _homeMap = HomePage(key: PageStorageKey("home"));
  static final CreatePost _createPost = CreatePost(
    key: PageStorageKey("createPost"),
  );
  static final OwnUserProfile _ownUserProfile = OwnUserProfile(
    key: PageStorageKey("profile"),
  );

  const CustomNavigationBar({super.key, required this.currentIndex});

  void _move(BuildContext context, Widget newWidget) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            PageStorage(bucket: _bucket, child: newWidget),
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
          _move(context, _homeMap);
        } else if (index == 1) {
          _move(context, _createPost);
        } else if (index == 2) {
          _move(context, _ownUserProfile);
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
