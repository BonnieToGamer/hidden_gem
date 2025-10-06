import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/services/geo_locator_service.dart';
import 'package:hidden_gem/widgets/gems_map.dart';
import 'package:latlong2/latlong.dart';

class PickOnMap extends StatefulWidget {
  final Function(LatLng) callback;

  PickOnMap({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() => _PickOnMapState();
}

class _PickOnMapState extends State<PickOnMap> {
  LatLng _position = defaultLocation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick location on map")),
      body: GemsMap(
        hasLocationPermission: GeolocatorService.hasLocationPermission,
        markers: [
          Marker(
            point: _position,
            rotate: true,
            child: Icon(
              Icons.location_pin,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
        onTapCallback: (position) {
          setState(() {
            _position = position;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.callback(_position);
          Navigator.pop(context);
        },
        label: const Text("Pick location"),
        foregroundColor: Theme.of(context).canvasColor,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
