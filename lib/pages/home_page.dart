import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/feed.dart';
import 'package:hidden_gem/widgets/home_map.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _HomeState { Map, Feed }

class _HomePageState extends State<HomePage> {
  _HomeState _state = _HomeState.Map;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _checkPermission()),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }

  // TODO: filters on e.g newly made posts
  Widget _homePage() {
    Widget stateWidget;

    if (_state == _HomeState.Map) {
      stateWidget = HomeMap();
    } else {
      stateWidget = Feed();
    }

    return Stack(
      children: [
        Expanded(child: stateWidget),
        Align(alignment: Alignment(0, -0.85), child: _buildSwitcher()),
      ],
    );
  }

  Widget _buildSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _switcherButton("Map", _HomeState.Map),
        SizedBox(
          height: 20,
          child: VerticalDivider(
            thickness: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        _switcherButton("Feed", _HomeState.Feed),
      ],
    );
  }

  Widget _switcherButton(String text, _HomeState state) {
    return SizedBox(
      width: 64,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          setState(() {
            _state = state;
          });
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: (_state == state)
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _checkPermission() {
    if (GeolocatorService.hasLocationPermission) {
      return _homePage();
    }

    return FutureBuilder(
      future: GeolocatorService.checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("There was an error getting location permission"),
          );
        }

        if (snapshot.hasData && snapshot.data == false) {
          final snackBar = SnackBar(
            content: const Text(
              "Location permission denied, please enable for best experience",
            ),
          );

          SchedulerBinding.instance.addPostFrameCallback(
            (duration) => ScaffoldMessenger.of(context).showSnackBar(snackBar),
          );
        }

        return _homePage();
      },
    );
  }
}
