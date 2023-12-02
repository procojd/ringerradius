import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart' as loc;
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart' as header;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart';
import 'package:location_app/controller/location_controller.dart';
import 'package:location_app/logic/background_logic.dart';
import 'package:location_app/logic/find_name.dart';
import 'package:location_app/logic/list_access.dart';
import 'package:location_app/model/model.dart';
import 'package:location_app/ui/homepage.dart';

class LocationAccess extends StatefulWidget {
  const LocationAccess({super.key});

  @override
  State<LocationAccess> createState() => _LocationAccessState();
}

class _LocationAccessState extends State<LocationAccess> {
  Location location = Location();

  final Map<String, Marker> _markers = {};

  double latitude = 0;
  double longitude = 0;
  GoogleMapController? _controller;
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(33.298037, 44.2879251),
    zoom: 10,
  );
  Future<void> _handleSearch() async {
    places.Prediction? p = await loc.PlacesAutocomplete.show(
        overlayBorderRadius: BorderRadius.circular(20),
        context: context,
        apiKey: 'your map key',
        onError: onError, // call the onError function below
        mode: loc.Mode.overlay,
        language: 'en', //you can set any language for search
        strictbounds: false,
        types: [],
        decoration: InputDecoration(
          hintText: 'search',
          hintStyle: TextStyle(fontWeight: FontWeight.normal),
          // fillColor: Colors.grey,
        ),
        components: [] // you can determine search for just one country
        );

    // displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(places.PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));
  }

  Future<void> displayPrediction(
      places.Prediction p, ScaffoldState? currentState) async {
    places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(
        // apiKey: kGoogleApiKey,
        apiHeaders: await const header.GoogleApiHeaders().getHeaders());
    places.PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(p.placeId!);
// detail will get place details that user chose from Prediction search
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    _markers.clear(); //clear old marker and set new one
    final marker = Marker(
      markerId: const MarkerId('deliveryMarker'),
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(
        title: '',
      ),
    );
    setState(() {
      _markers['myLocation'] = marker;
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 15),
        ),
      );
    });
  }

  getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData currentPosition = await location.getLocation();
    latitude = currentPosition.latitude!;
    longitude = currentPosition.longitude!;
    final marker = Marker(
      markerId: const MarkerId('myLocation'),
      position: LatLng(latitude, longitude),
      infoWindow: const InfoWindow(
        title: 'you can add any message here',
      ),
    );
    setState(() {
      _markers['myLocation'] = marker;
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(latitude, longitude), zoom: 15),
        ),
      );
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    alreadylocation(longitude, latitude);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocationController controller = Get.find();
    final ColorScheme col = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller1) {
                      controller.mapController.isCompleted
                          ? null
                          : controller.mapController.complete(controller1);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: controller.selectedLocation,
                      zoom: 14.4746,
                    ),
                    markers: <Marker>{
                      Marker(
                        markerId: const MarkerId('Selected_Location'),
                        position: controller.selectedLocation,
                        onTap: () {
                          print(controller.selectedLocation);
                        },
                      ),
                    },
                    onTap: (LatLng location) async {
                      await findName();
                      setState(() {
                        controller.selectedLocation = location;
                      });
                      alreadylocation(controller.selectedLocation.longitude,
                          controller.selectedLocation.latitude);
                    },
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top:
                    10, // you can change place of search bar any where on the map
                child: ElevatedButton(
                    onPressed: _handleSearch, child: Text('search')),
              )
            ]),
          ),
          Expanded(
            child: Container(
              // height: MediaQuery.sizeOf(context).height * 0.3,
              // color: Colors.red,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          // color: col.surfaceVariant,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.location_circle_fill,
                                  color: Color.fromARGB(255, 33, 65, 243),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Location Selected",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                Spacer(),
                                Text("${controller.locationName}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      // color: Colors.grey
                                    )),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.more_horiz_rounded,
                                  color: Color.fromARGB(255, 6, 190, 0),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Latitude",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                Spacer(),
                                Text("${controller.selectedLocation.latitude}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      // color: Colors.grey
                                    )),
                              ],
                            ),
                            Divider(
                              thickness: 0.5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.more_vert_rounded,
                                  color: Color.fromARGB(255, 240, 148, 0),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Longitude",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                                Spacer(),
                                Text("${controller.selectedLocation.longitude}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      // color: Colors.grey
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.sizeOf(context).width,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Colors.grey[200],
                          hintText: 'Select a Location or Enter Manually',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                        ),
                        onChanged: (newValue) {
                          TextEditingController textController =
                              TextEditingController();
                          if (newValue == "Add Manually") {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter Location Name'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextField(
                                        controller: textController,
                                        decoration: InputDecoration(
                                          hintText: 'Location Name',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        // Cancel button pressed
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (textController.text.isNotEmpty) {
                                          setState(() {
                                            controller.ln.value = textController
                                                .text; // Update selectedValue
                                          });
                                        } else {
                                          setState(() {
                                            controller.ln.value =
                                                "Empty"; // Update selectedValue
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              controller.ln.value = newValue!;
                            });
                          }
                        },
                        items: <String>[
                          'Add Manually',
                          'Home',
                          'College/School',
                          'Work',
                          'Temple',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.tonal(
                          style: ElevatedButton.styleFrom(
                              // backgroundColor:
                              //     const Color.fromARGB(255, 230, 230, 230)
                              ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16),
                            child: const Icon(
                              Icons.close_rounded,
                              // color: Colors.black,
                            ),
                          )),
                      FilledButton(
                          onPressed: () async {
                            print(controller.selectedLocation.longitude);

                            if (await alreadylocation(
                                controller.selectedLocation.longitude,
                                controller.selectedLocation.latitude)) {
                              controller.dataToShow.value.add(
                                Data(
                                  ssid: 'null',
                                  name: controller.ln.value ?? 'Recent',
                                  // name: controller.locationName,
                                  latitude:
                                      controller.selectedLocation.latitude,
                                  longitude:
                                      controller.selectedLocation.longitude,
                                  volumeLevel: 0.0,
                                  ringerMode: 0.0,
                                  timeHour: -1,
                                  timeMinute: -1,
                                ),
                              );

                              controller.update();
                              storingData(controller.dataToShow.value);
                              Navigator.of(context).pop();
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Alert'),
                                    content: Text(
                                        'Location Already exist in 50 metre range'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          // style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color.fromARGB(255, 0, 46, 231)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16),
                            child: const Icon(
                              Icons.done_rounded,
                              // color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(
      title: 'hello1',
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
