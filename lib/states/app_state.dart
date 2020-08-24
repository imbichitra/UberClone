import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uberclone/requests/google_maps_request.dart';

class AppState extends ChangeNotifier {
  bool locationServiceActive = true;
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng get initalPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get googleMapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  GoogleMapsPlaces get places => _places;

  

  AppState() {
    _getUserLocation();
    _loadingInitialPosition();
  }

  //TO GET THE USER LOCZATION
  void _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> plaemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    _initialPosition = LatLng(position.latitude, position.longitude);
    locationController.text = plaemark[0].name;
    notifyListeners();
  }

  //TO CRETE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
      polylineId: PolylineId(_lastPosition.toString()),
      width: 5,
      points: _convertToLatLng(_decodePoly(encondedPoly)),
      color: Colors.black,
    ));
    notifyListeners();
  }

  // ADD A MARKER
  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  /*
  *[12.12,13.13,133.3,33131]
  */
  //this method will convert list of double into latlng
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
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

  //SEND REQUEST
  void sendRequest(String intendLocation) async {
    List<Placemark> plaemark =
        await Geolocator().placemarkFromAddress(intendLocation);
    double latitude = plaemark[0].position.latitude;
    double longitude = plaemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendLocation);
    String route = await _googleMapsServices.getRouteCoordinate(
        _initialPosition, destination);
    createRoute(route);
    notifyListeners();
  }

  void sendRequest1(LatLng destination,String address)async{
    _addMarker(destination, address);
     String route = await _googleMapsServices.getRouteCoordinate(
        _initialPosition, destination);
    createRoute(route);
    notifyListeners();
  }

  void onCameraMove(CameraPosition position) {
    //debugPrint('Console Message Using Debug Print');
    _lastPosition = position.target;
    notifyListeners();
  }

  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  //  LOADING INITIAL POSITION
  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(_initialPosition == null){
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }
}
