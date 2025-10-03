import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/pages/view_post.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/gems_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  final List<Marker> _currentMarkers = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);

    return StreamBuilder<List<Post>>(
      stream: PostsService.getAllPosts(user.uid),
      builder: (context, snapshot) {
        return GemsMap(
          hasLocationPermission: GeolocatorService.hasLocationPermission,
          markers: _postMarkers(context, snapshot),
        );
      },
    );
  }

  List<Marker> _postMarkers(
    BuildContext context,
    AsyncSnapshot<List<Post>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _currentMarkers;
    }

    if (snapshot.hasData == false) {
      return _currentMarkers;
    }

    final posts = snapshot.data!;

    final newMarkers = posts.map((post) {
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
              MaterialPageRoute(builder: (context) => ViewPost(post: post)),
            );
          },
          child: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }).toList();

    _currentMarkers.clear();
    _currentMarkers.addAll(newMarkers);

    return _currentMarkers;
  }
}
