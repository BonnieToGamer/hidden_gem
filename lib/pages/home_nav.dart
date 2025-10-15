import 'package:flutter/material.dart';
import 'package:hidden_gem/pages/home_page.dart';
import 'package:hidden_gem/pages/post/create_post.dart';
import 'package:hidden_gem/pages/user_profile/own_user_profile.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  late int _selectedPageIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = 0;
    _pages = [HomePage(), CreatePost(), OwnUserProfile()];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTapCallback: _onTapCallback,
      ),
    );
  }

  void _onTapCallback(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }
}
