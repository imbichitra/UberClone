import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/lat_lng_interpolation.dart';
import 'package:flutter_animarker/models/lat_lng_delta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uberclone/requests/google_maps_request.dart';
import 'dart:ui' as ui;

class AnimateMarker extends StatefulWidget {
  @override
  _AnimateMarkerState createState() => _AnimateMarkerState();
}

class _AnimateMarkerState extends State<AnimateMarker> {
  final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  MarkerId sourceId = MarkerId("SourcePin");

  LatLngInterpolationStream _latLngStream = LatLngInterpolationStream(
    movementDuration: Duration(milliseconds: 2000),
  );

  StreamSubscription<LatLngDelta> subscription;

  final Completer<GoogleMapController> _controller = Completer();

  LatLng initialPositin = LatLng(19.450285, 84.673330);//19.450285, 84.673330
  LatLng currentPositin = LatLng(19.464600, 84.662271);

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  List<LatLng> result = <LatLng>[];

  LatLng lastPosition;
  BitmapDescriptor pinLocationIcon;
  void createMaprker() async {
    // final Uint8List markerIcon =
    //     await getBytesFromAsset('assets/car_icon.png', 100);
    // pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
  
    pinLocationIcon =  await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 'assets/car_icon.png');
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    createMaprker();
    subscription =
        _latLngStream.getLatLngInterpolation().listen((LatLngDelta delta) {
      //Update the animated marker
      setState(() {
        Marker sourceMarker = Marker(
          markerId: sourceId,
          rotation: delta.rotation+130,
          icon: pinLocationIcon,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5,0.5),
          position: LatLng(
            delta.from.latitude,
            delta.from.longitude,
          ),
        );
        _markers[sourceId] = sourceMarker;
      });
      lastPosition = delta.to;
      Future.delayed(Duration(seconds: 5), () async {
        moveCamera(lastPosition);
      });
      // if (polygon.isNotEmpty) {
      //   //Pop the last position
      //   _latLngStream.addLatLng(polygon.removeLast());
      // }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers.values),
            initialCameraPosition:
                CameraPosition(target: initialPositin, zoom: 15.0),
            onMapCreated: _onMapCreated,
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
    _controller.complete(controller);
    if (initialPositin != null) {
      //LatLng position = initialPositin;
      Marker marker = Marker(
          markerId: sourceId, position: initialPositin, icon: pinLocationIcon
          //draggable: false,
          );

      setState(() {
        _markers[sourceId] = marker;
      });

      _latLngStream.addLatLng(initialPositin);
    }
  }

  Future<void> _onAddMarkerPressed() async {
    //_latLngStream.addLatLng(currentPositin);
    String route = await _googleMapsServices.getRouteCoordinate(
        initialPositin, currentPositin);
    _convertToLatLng(_decodePoly(route));
    updateMarkerPosition();
  }

  Future<void> updateMarkerPosition() async {
    //  Future.delayed(const Duration(milliseconds: 4000), () {
    //             _latLngStream.addLatLng(result.removeLast());
    //           });

    for (int i = 0; i < result.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _latLngStream.addLatLng(result[i]);
    }
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

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void moveCamera(LatLng to) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          //bearing: 192.8334901395799,
          tilt: 0,
          target: to,
          zoom: 17.0,
        ),
      ),
    );
  }
}
