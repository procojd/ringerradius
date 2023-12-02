import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/model.dart';

class LocationController extends GetxController {
  var dataToShow = <Data>[].obs;
  var ln = "".obs;
  late LatLng selectedLocation;
  late String locationName = "Not Found";
  RxDouble axis = 0.0.obs;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  var onboarding = false.obs;
  var drivng = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
}
