import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/requests/google_maps_request.dart';
import 'package:uberclone/states/app_state.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: appState.initalPosition == null
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              SpinKitFoldingCube(
              color: Colors.black,
                size: 50.0,
              )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Visibility(
                    visible: appState.locationServiceActive == false,
                    child: Text("Please enable location services!", style: TextStyle(color: Colors.grey, fontSize: 18),),
                  )
                ],
              )
            )
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: appState.initalPosition, zoom: 10.0),
                  onMapCreated: appState.onCreated,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  markers: appState.markers,
                  onCameraMove: appState.onCameraMove,
                  polylines: appState.polyLines,
                ),

                Positioned(
                  top: 50.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: appState.locationController,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, top: 5),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "pick up",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 105.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      // onTap: ()async{
                      //   Prediction p = await PlacesAutocomplete.show(
                      //     context: context, apiKey: apiKey,language: "pt",
                      //     components: [
                      //       Component(Component.country, "in")
                      //     ]);
                      //     if(p != null){
                      //       PlacesDetailsResponse detail = await appState.places.getDetailsByPlaceId(p.placeId);
                      //         double lat = detail.result.geometry.location.lat;
                      //         double lng = detail.result.geometry.location.lng;
                      //         LatLng destination = LatLng(lat, lng);
                      //         var address = await Geocoder.local.findAddressesFromQuery(p.description);
                      //         appState.sendRequest1(destination,address[0].addressLine);
                      //     }
                      // },
                      cursorColor: Colors.black,
                      controller: appState.destinationController,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (value) {
                        appState.sendRequest(value);
                      },
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, top: 5),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.local_taxi,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "destination?",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 40,
                //   right: 20,
                //   child: FloatingActionButton(onPressed: _onAddMarkerPressed,
                //   tooltip: "add marker",
                //   backgroundColor: black,
                //   child: Icon(Icons.add_location,color: white,)),
                // )
              ],
            ),
    );
  }
}
