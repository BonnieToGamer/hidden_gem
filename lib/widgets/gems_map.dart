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
  final bool hasLocationPermission;

  const GemsMap(
      {super.key, this.markers, this.onTapCallback, required this.hasLocationPermission});

  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<GemsMap> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _mapCenter = defaultLocation;
  LatLng? _preciseLocation;
  final double _currentZoom = 16;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (widget.hasLocationPermission == false) {
      return;
    }

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
          MarkerLayer(markers: [
            ...?widget.markers,
            ?(widget.hasLocationPermission && _preciseLocation != null)
                ? Marker(
              point: _preciseLocation!,
              width: 40,
              height: 40,
              rotate: true,
              child: CircleAvatar(
                child: Icon(Icons.person),
              ),
            )
                : null,
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