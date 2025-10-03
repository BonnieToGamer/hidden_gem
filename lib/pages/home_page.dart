import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/pages/view_post.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/gems_map.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _checkPermission()),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 0),
    );
  }

  // TODO: filters on e.g newly made posts
  Widget _homePage() {
    final user = Provider.of<User>(context, listen: false);

    return StreamBuilder<List<Post>>(
      stream: PostsService.getAllPosts(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        final posts = snapshot.data!;
        return GemsMap(
          hasLocationPermission: GeolocatorService.hasLocationPermission,
          markers: posts.map((post) {
            return Marker(
              point: LatLng(
                post.point.geopoint.latitude,
                post.point.geopoint.longitude,
              ),
              rotate: true,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPost(post: post),
                    ),
                  );
                },
                child: Icon(
                  Icons.location_pin,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  FutureBuilder<bool> _checkPermission() {
    return FutureBuilder(
      future: GeolocatorService.checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("There was an error getting location permission"));
        }

        if (snapshot.hasData && snapshot.data == false) {
          final snackBar = SnackBar(
              content: const Text(
                  "Location permission denied, please enable for best experience")
          );

          SchedulerBinding.instance.addPostFrameCallback((duration) =>
              ScaffoldMessenger.of(context).showSnackBar(snackBar));
        }

        return _homePage();
      },
    );
  }
}
