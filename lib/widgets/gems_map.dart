import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class GemsMap extends StatefulWidget {
  final List<Marker>? markers;
  final Function(LatLng position)? onTapCallback;

  const GemsMap({super.key, this.markers, this.onTapCallback});

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<GemsMap> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _mapCenter = defaultLocation;
  LatLng _currentMapPos = defaultLocation;
  LatLng? _preciseLocation;
  double _currentZoom = 16;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final lastPosition = await GeolocatorService.getLastLocation();
      if (lastPosition != null)
      {
        if (!mounted) return;

        setState(() {
          _mapCenter = LatLng(
            lastPosition.latitude,
            lastPosition.longitude,
          );

          _preciseLocation = LatLng(
            lastPosition.latitude,
            lastPosition.longitude,
          );
        });

        _mapController.move(_mapCenter, _currentZoom);
      }

      final highAccuracyPosition = await GeolocatorService.getCurrentLocation(accuracy: LocationAccuracy.high);

      if (!mounted) return;
      setState(() {
        _preciseLocation = LatLng(
          highAccuracyPosition.latitude,
          highAccuracyPosition.longitude,
        );
      });

    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  // https://stackoverflow.com/a/73210147/16052290
  // modified to work by me :D
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(begin: _currentMapPos.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _currentMapPos.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _currentZoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation)
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _currentZoom,
        onPositionChanged: (mapCamera, hasGesture) {
          if (widget.onTapCallback != null) widget.onTapCallback!(mapCamera.center);
        }
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: userAgent,
        ),
        if (_preciseLocation != null)
          MarkerLayer(markers: [
            Marker(
              point: _preciseLocation!,
              width: 40,
              height: 40,
              rotate: true,
              child: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ...?widget.markers
          ]),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () async {
                if (!await launchUrl(Uri.parse('https://openstreetmap.org/copyright'))) {
                  throw Exception("Could not launch https://openstreetmap.org/copyright");
                }
              },
              prependCopyright: true,
            )
          ],
          showFlutterMapAttribution: false,
        )
      ],
    );
  }
}