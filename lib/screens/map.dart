import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Maps(),
    );
  }
}

class Maps extends StatefulWidget {
  Maps({Key key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 0;
  Completer<GoogleMapController> _mapController = Completer();

  LatLng initialPositin = LatLng(20.296059, 85.824539);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                CameraPosition(target: initialPositin, zoom: 16.0),
            myLocationEnabled: true,
            onCameraMove: (CameraPosition position) {
              if (_markers.length > 0) {
                MarkerId markerId = MarkerId(_markerIdVal());
                Marker marker = _markers[markerId];
                Marker updatedMarker = marker.copyWith(
                  positionParam: position.target,
                );

                setState(() {
                  _markers[markerId] = updatedMarker;
                });
              }
            },
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    if (initialPositin != null) {
      MarkerId markerId = MarkerId(_markerIdVal());
      LatLng position = initialPositin;
      Marker marker = Marker(
        markerId: markerId,
        position: position,
        draggable: false,
      );
      setState(() {
        _markers[markerId] = marker;
      });

      Future.delayed(Duration(seconds: 1), () async {
        GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: 17.0,
            ),
          ),
        );
      });
    }
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }
}
