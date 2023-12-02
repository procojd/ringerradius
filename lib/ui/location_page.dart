import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_app/logic/find_name.dart';

import '../controller/location_controller.dart';
import '../logic/background_logic.dart';
import '../logic/list_access.dart';
import '../model/model.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    super.initState();
    alreadylocation(controller.selectedLocation.longitude, controller.selectedLocation.longitude);
  }
  final LocationController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller1) {
                controller.mapController.isCompleted?null:
                controller.mapController.complete(controller1);
              },
              mapType: MapType.normal,
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
          Container(
            height: 150,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Location Selected -> ${controller.locationName}"),
                Text("Latitude -> ${controller.selectedLocation.latitude}"),
                Text("Longitude -> ${controller.selectedLocation.longitude}"),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("X")),
                    ElevatedButton(
                        onPressed: () {
                          controller.dataToShow.value.add(
                            Data(
                              ssid:'null',
                              name: controller.locationName,
                              latitude: controller.selectedLocation.latitude,
                              longitude: controller.selectedLocation.longitude,
                              volumeLevel: 0.0,
                              ringerMode: 0.0,
                              timeHour: -1,
                              timeMinute: -1,
                            ),
                          );
                          Navigator.of(context).pop();
                          controller.update();
                          storingData(controller.dataToShow.value);
                          
                        },
                        child: const Text("✔")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
