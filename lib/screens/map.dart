import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uberclone/requests/google_maps_request.dart';

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

  LatLng initialPositin = LatLng(20.347919, 85.809492);
  LatLng currentPositin = LatLng(20.353516, 85.821628);
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  List<LatLng> result = <LatLng>[];

  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    super.initState();
  }

  createImage(context){
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, 'asswts/logo.png')
    .then((value) => {
      setState((){
        pinLocationIcon = value;
      })
    });
  }
  @override
  Widget build(BuildContext context) {
    createImage(context);
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: _onMapCreated,
            initialCameraPosition:
                CameraPosition(target: initialPositin, zoom: 16.0),
            myLocationEnabled: true,
            mapType: MapType.normal,
            polylines: _polyLines,
            onCameraMove: (CameraPosition position) async {
              if (_markers.length > 0) {
                // MarkerId markerId = MarkerId(_markerIdVal());
                // Marker marker = _markers[markerId];
                // Marker updatedMarker = marker.copyWith(
                //   positionParam: position.target,
                // );

                // setState(() {
                //   _markers[markerId] = updatedMarker;
                // });
                //currentPositin = position.target;
              }
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
                onPressed: _onAddMarkerPressed,
                tooltip: "add marker",
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.add_location,
                  color: Colors.white,
                )),
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
        //icon: pinLocationIcon,
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

  List<LatLng> _convertToLatLng(List points) {
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        //getting lat lng from array
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  //DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  Future<void> _onAddMarkerPressed() async {
    String route = await _googleMapsServices.getRouteCoordinate(
        initialPositin, currentPositin);

    // MarkerId markerId = MarkerId(_markerIdVal());
    // Marker marker = _markers[markerId];
    // Marker updatedMarker = marker.copyWith(
    //   positionParam: currentPositin,
    // );
    setState(() {
      _polyLines.add(Polyline(
        polylineId: PolylineId("ll"),
        width: 5,
        points: _convertToLatLng(_decodePoly(route)),
        color: Colors.black,
      ));

      // _markers[markerId] = updatedMarker;
      updateMarkerPosition();
    });
  }

  Future<void> updateMarkerPosition() async {
    for (int i = 0; i < result.length-1; i++) {
      MarkerId markerId = MarkerId(_markerIdVal());
      Marker marker = _markers[markerId];

      Marker updatedMarker = marker.copyWith(
        positionParam: result[i],
      );
      Future.delayed(Duration(seconds: 1), () async {
        GoogleMapController controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: result[i],
              zoom: 17.0,
            ),
          ),
        );
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        _markers[markerId] = updatedMarker;
      });

      
      
    }
  }
}
