import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:location_app/controller/location_controller.dart';

findName() async {
  LocationController controller = Get.put(LocationController());
  final name = await placemarkFromCoordinates(
      controller.selectedLocation.latitude,
      controller.selectedLocation.longitude);
  controller.locationName = name[0].name ?? "Name not found";
}