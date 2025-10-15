import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class GemsMap extends StatefulWidget {
  final List<Marker>? markers;
  final Function(LatLng position)? onTapCallback;
  final bool hasLocationPermission;

  const GemsMap({
    super.key,
    this.markers,
    this.onTapCallback,
    required this.hasLocationPermission,
  });

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<GemsMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final double _currentZoom = 16;
  late AnimationController _mapMoveController;
  Tween<double>? _latTween;
  Tween<double>? _lngTween;
  Tween<double>? _zoomTween;
  CurvedAnimation? _mapAnimation;
  LatLng _mapCenter = defaultLocation;
  bool _isOnCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();

    _mapMoveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _mapMoveController.addListener(_mapMoveControllerListener);

    _mapAnimation = CurvedAnimation(
      parent: _mapMoveController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _mapMoveControllerListener() {
    if (_latTween == null ||
        _lngTween == null ||
        _zoomTween == null ||
        _mapAnimation == null) {
      return;
    }

    _mapController.move(
      LatLng(
        _latTween!.evaluate(_mapAnimation!),
        _lngTween!.evaluate(_mapAnimation!),
      ),
      _zoomTween!.evaluate(_mapAnimation!),
    );

    final finalPos = LatLng(_latTween!.end!, _lngTween!.end!);
    if (_mapController.camera.center == finalPos) {
      setState(() {
        _isOnCurrentLocation = true;
      });
    }
  }

  @override
  void dispose() {
    _mapMoveController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    if (widget.hasLocationPermission == false) {
      return;
    }

    try {
      final lastPosition = await GeolocatorService.getLastLocation();
      if (lastPosition != null) {
        if (!mounted) return;

        setState(() {
          _mapCenter = LatLng(lastPosition.latitude, lastPosition.longitude);
        });

        _mapController.move(_mapCenter, _currentZoom);

        setState(() {
          _isOnCurrentLocation = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  // https://stackoverflow.com/a/73210147/16052290
  // modified to work by me :D
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    _latTween = Tween<double>(
      begin: _mapCenter.latitude,
      end: destLocation.latitude,
    );
    _lngTween = Tween<double>(
      begin: _mapCenter.longitude,
      end: destLocation.longitude,
    );
    _zoomTween = Tween<double>(begin: _currentZoom, end: destZoom);

    _mapMoveController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _currentZoom,
        onPositionChanged: (mapCamera, hasGesture) {
          _mapCenter = mapCamera.center;

          if (widget.onTapCallback != null) {
            widget.onTapCallback!(mapCamera.center);
          }

          setState(() {
            _isOnCurrentLocation = false;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: userAgent,
        ),
        CurrentLocationLayer(
          alignPositionOnUpdate: AlignOnUpdate.never,
          alignDirectionOnUpdate: AlignOnUpdate.never,
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 16,
            zoomToBoundsOnClick: true,
            showPolygon: false,
            rotate: true,
            markers: [...?widget.markers],
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () async {
                if (!await launchUrl(
                  Uri.parse('https://openstreetmap.org/copyright'),
                )) {
                  throw Exception(
                    "Could not launch https://openstreetmap.org/copyright",
                  );
                }
              },
              prependCopyright: true,
            ),
          ],
          showFlutterMapAttribution: false,
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              onPressed: () async {
                final lastPosition = await GeolocatorService.getLastLocation();

                if (lastPosition == null) return;

                final position = LatLng(
                  lastPosition.latitude,
                  lastPosition.longitude,
                );
                _animatedMapMove(position, 16);
              },
              icon: Icon(
                _isOnCurrentLocation
                    ? Icons.my_location
                    : Icons.location_searching,
                color: Theme.of(context).canvasColor,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
