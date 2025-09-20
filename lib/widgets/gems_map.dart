import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class GemsMap extends StatefulWidget {
  const GemsMap({super.key});
  
  @override
  State<StatefulWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<GemsMap> {
  final MapController _mapController = MapController();
  LatLng _mapCenter = LatLng(56.18225794423523, 15.590843776151345); // default location: BTH :)
  LatLng? _preciseLocation;

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

        _mapController.move(_mapCenter, 16);
      }

      final highAccuracyPosition = await GeolocatorService.getCurrentLocation(LocationAccuracy.high);
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

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'hidden-gem-pa1414-bth',
        ),
        if (_preciseLocation != null)
          MarkerLayer(markers: [
            Marker(
                point: _preciseLocation!,
                width: 40,
                height: 40,
                child: CircleAvatar(
                  child: Icon(Icons.person),
                )
            )
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
            )
          ],
          showFlutterMapAttribution: false,
        )
      ],
    );
  }
}