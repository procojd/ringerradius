import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_mute/flutter_mute.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location_app/controller/location_controller.dart';
import 'package:location_app/logic/list_access.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../model/model.dart';

//This code will work in background and give data to our UI
LocationController lc = Get.put(LocationController());
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on("setAsBackgroundService").listen((event) {
      service.setAsBackgroundService();
    });
    service.on("setAsForegroundService").listen((event) {
      service.setAsForegroundService();
    });
  }
  Map<String, double> fetchingLocation1 = {};
 

// print(now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString());

  // accelerometerEvents.listen((AccelerometerEvent event) {
  //   // You can customize the sensitivity threshold based on your requirement
  //   double motionThreshold = 1.0;
  //   double totalAcceleration = event.x.abs() + event.y.abs() + event.z.abs();
  //   if (totalAcceleration > motionThreshold) {
  //     backgroundlocation(service);
  //   } else {}
  // });
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  _streamSubscriptions.add(
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        // print(event);
        // double x, y;
         DateTime now = DateTime.now();
        lc.axis.value = event.x;
        // print(now.minute);
        if (event.x > 2 && now.minute % 2 == 0) {
          // print(event.x);
          // setState(() {
          //   HapticFeedback.selectionClick();
          //   // _userAccelerometerValues = <double>[event.x, event.y, event.z];
          //   // if (_userAccelerometerValues!.any((element) => element > 0.1)) {
          //   appbarname = 'test';
          //   // }
          // });
          LocationSettings settings = LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          );

          Geolocator.getPositionStream(locationSettings: settings)
              .listen((position) async {
            List<Data> dataToShow = await gettingData();
            if (event.x > 2) {
              fetchingLocation1 = {
                "speed": (position.speed * 3.6),
                "lat": position.latitude,
                "long": position.longitude
              };
              double latitude = position.latitude;
              double longitude = position.longitude;
              double speedMps = (position.speed * 3.6);
              // print(longitude);
              // print(latitude);
              if (speedMps > 10) {
                await FlutterMute.setRingerMode(RingerMode.Silent);
              }
              for (var element in dataToShow) {
                if ((double.parse(latitude.toStringAsFixed(3)) -
                                double.parse(
                                    element.latitude.toStringAsFixed(3)) ==
                            0) &&
                        (double.parse(longitude.toStringAsFixed(3)) -
                                double.parse(
                                    element.longitude.toStringAsFixed(3)) ==
                            0) ||
                    (DateTime.now().hour - element.timeHour == 0 &&
                        DateTime.now().minute - element.timeMinute == 0)) {
                  // print(element.volumeLevel);
                  // print("Data Matched");
                  PerfectVolumeControl.setVolume(element.volumeLevel / 100.0);

                  if (element.ringerMode == 0.0) {
                    FlutterMute.setRingerMode(RingerMode.Normal);
                    print("Set Normal");
                  } else if (element.ringerMode == 1.0) {
                    FlutterMute.setRingerMode(RingerMode.Vibrate);
                    print("Set Vibrate");
                  } else if (element.ringerMode == 2.0) {
                    FlutterMute.setRingerMode(RingerMode.Silent);
                    print("Set Silent");
                  }
                  PerfectVolumeControl.hideUI = true;
                }
                // lc.axis.value = event.x;
                // print('new event x');
                // print(lc.axis.value);
              }
            }

            // service.invoke('LocationData', fetchingLocation);
          });
        }
        // lc.axis.value = event.x;
      },
      onError: (e) {
        print(e);
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return const AlertDialog(
        //         title: Text("Sensor Not Found"),
        //         content: Text(
        //             "It seems that your device doesn't support Accelerometer Sensor"),
        //       );
        //     });
      },
      cancelOnError: true,
    ),
  );

  service.invoke('LocationData', fetchingLocation1);
}

void backgroundlocation(ServiceInstance service) async {
  LocationSettings settings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );

  Geolocator.getPositionStream(locationSettings: settings)
      .listen((position) async {
    List<Data> dataToShow = await gettingData();
    Map<String, double> fetchingLocation = {
      "speed": (position.speed * 3.6),
      "lat": position.latitude,
      "long": position.longitude
    };
    double latitude = position.latitude;
    double longitude = position.longitude;
    double speedMps = (position.speed * 3.6);
    print(longitude);
    print(latitude);
    if (speedMps > 10) {
      await FlutterMute.setRingerMode(RingerMode.Silent);
    }
    for (var element in dataToShow) {
      if ((double.parse(latitude.toStringAsFixed(3)) -
                      double.parse(element.latitude.toStringAsFixed(3)) ==
                  0) &&
              (double.parse(longitude.toStringAsFixed(3)) -
                      double.parse(element.longitude.toStringAsFixed(3)) ==
                  0) ||
          (DateTime.now().hour - element.timeHour == 0 &&
              DateTime.now().minute - element.timeMinute == 0)) {
        print(element.volumeLevel);
        print("Data Matched");
        PerfectVolumeControl.setVolume(element.volumeLevel / 100.0);

        if (element.ringerMode == 0.0) {
          FlutterMute.setRingerMode(RingerMode.Normal);
          print("Set Normal");
        } else if (element.ringerMode == 1.0) {
          FlutterMute.setRingerMode(RingerMode.Vibrate);
          print("Set Vibrate");
        } else if (element.ringerMode == 2.0) {
          FlutterMute.setRingerMode(RingerMode.Silent);
          print("Set Silent");
        }
        PerfectVolumeControl.hideUI = true;
      }
    }
    service.invoke('LocationData', fetchingLocation);
  });
}

// void setvolumewifi() async {
//   List<Data> dataToShow = await gettingData();
//   for (var element in dataToShow) {
//     if (element.ssid == await getWifiName()) {
//       print(element.volumeLevel);
//       print("Data Matched");
//       PerfectVolumeControl.setVolume(element.volumeLevel / 100.0);
//       if (element.ringerMode == 0.0) {
//         FlutterMute.setRingerMode(RingerMode.Normal);
//         print("Set Normal");
//       } else if (element.ringerMode == 1.0) {
//         FlutterMute.setRingerMode(RingerMode.Vibrate);
//         print("Set Vibrate");
//       } else if (element.ringerMode == 2.0) {
//         FlutterMute.setRingerMode(RingerMode.Silent);
//         print("Set Silent");
//       }
//       PerfectVolumeControl.hideUI = true;
//     }
//   }
// }

// Future<String> getWifiName() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//   if (connectivityResult == ConnectivityResult.wifi) {
//     String? wifiSSID = await NetworkInfo().getWifiName();
//     print('wifi ssid:');
//     print(wifiSSID);
//     return wifiSSID ?? 'test';
//   }
//   return 'null';
// }

Future<bool> alreadywifi(String currentwifi) async {
  List<Data> dataToShow = await gettingData();
  print("Wifi Data Fetched");
  for (var element in dataToShow) {
    if (element.ssid == currentwifi) {
      print('wifi is there');
      return false;
    }
  }
  print('wifi is not there');
  return true;
}

// Future<bool> alreadylocation(double longitude, double latitude) async {
//   List<Data> dataToShow = await gettingData();
//   print("Location Data Fetched");
//   for (var element in dataToShow) {
//     print('check');
//     print(element.longitude);
//     if (((element.longitude - longitude).abs() <= 0.00004) ||
//         ((element.latitude - latitude).abs() <= 0.00004)) {
//       print('location is under 50 m');
//       return false;
//     }
//   }
//   print('no location near 50 m');
//   return true;
// }
const double earthRadius = 6371000;
Future<bool> alreadylocation(
    double currentLongitude, double currentLatitude) async {
  List<Data> dataToShow = await gettingData();
  print("Location Data Fetched");

  for (var element in dataToShow) {
    double distance = calculateDistance(
      currentLatitude,
      currentLongitude,
      element.latitude,
      element.longitude,
    );

    if (distance <= 50.0) {
      print('Location is within 50 meters');
      return false;
    }
  }

  print('No location within 50 meters');
  return true;
}

double degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}

double calculateDistance(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) {
  double dLat = degreesToRadians(endLatitude - startLatitude);
  double dLon = degreesToRadians(endLongitude - startLongitude);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(degreesToRadians(startLatitude)) *
          cos(degreesToRadians(endLatitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c;
  return distance;
}
