import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mute/flutter_mute.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_app/logic/find_name.dart';
import 'package:location_app/logic/volume.dart';
import 'package:location_app/model/model.dart';
import 'package:location_app/permissions/location_permission.dart';
import 'package:location_app/ui/colors.dart';
import 'package:location_app/ui/location2.dart';
import 'package:location_app/ui/locationedit.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import '../controller/location_controller.dart';
import '../logic/background_logic.dart';
import '../logic/list_access.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  double latitude = 0;
  double longitude = 0;
  double speedMps = 0;
  double _value = 30;
  double normalVolume = 0.0;
  bool fetchingLoader = false;
  double selectedRingerMode = 0.0;
  TimeOfDay? time;
  LocationController controller = Get.put(LocationController());

  dndCheck() async {
    bool isAccessGranted = await FlutterMute.isNotificationPolicyAccessGranted;
    if (!isAccessGranted) {
      await FlutterMute.openNotificationPolicySettings();
    }
    controller.dataToShow.value = await gettingData();
    setState(() {});
    await fetchingData();
  }

  String appbarname = 'RingerRadius';

  fetchingData() async {
    fetchingLoader = true;
    setState(() {});
    Position position = await determinePosition();
    latitude = position.latitude;
    longitude = position.longitude;
    print(latitude);
    print(longitude);
    if (await Geolocator.checkPermission() == LocationPermission.denied ||
        await Geolocator.checkPermission() ==
            LocationPermission.deniedForever) {
      //Doing nothing
    } else {
      FlutterBackgroundService().configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
        ),
        iosConfiguration: IosConfiguration(),
      );
      FlutterBackgroundService().on('LocationData').listen((event) {
        latitude = event!['lat'];
        longitude = event['long'];
        speedMps = event['speed'] == 0 ? 0.0 : event['speed'];
        fetchingLoader = false;
        setState(() {});
      });
      fetchingLoader = false;
      setState(() {});
    }
  }

  List<double>? _userAccelerometerValues;
  late AudioManager audioManager;
  late int maxVol, currentVol;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    print('check1');

    dndCheck();
    PerfectVolumeControl.hideUI = true;
    super.initState();
    // audioManager = AudioManager.STREAM_SYSTEM;
    // initAudioStreamType();
  }

  // Future<void> initAudioStreamType() async {
  //   await Volume.controlVolume(AudioManager.STREAM_SYSTEM);
  //   updateVolumes();
  // }

  // updateVolumes() async {
  //   // get Max Volume
  //   maxVol = await Volume.getMaxVol;
  //   print(maxVol);
  //   // get Current Volume
  //   currentVol = await Volume.getVol;
  //   setVol(maxVol);
  //   setState(() {});
  // }

  setVol(int i) async {
    await Volume.setVol(i, showVolumeUI: ShowVolumeUI.SHOW);
    // or
    // await Volume.setVol(i, showVolumeUI: ShowVolumeUI.HIDE);
  }

  @override
  void dispose() {
    print("background mode");
    FlutterBackgroundService().invoke('setAsBackgroundService');
    super.dispose();
  }

  int selectedOption = 0;
  Widget alertBoxData(int index, Function updateListCallback) {
    TextEditingController nameController = TextEditingController();
    nameController.text = controller.dataToShow.value[index].name.toString();
    LatLng selectedLocation = LatLng(
        controller.dataToShow.value[index].latitude,
        controller.dataToShow.value[index].longitude);
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        final ColorScheme col = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              color: col.surface
              // color: Colors.white,
              ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Name',
                      style: TextStyle(color: col.onSurface),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        // label: Text('Name'),
                        filled: true,
                        fillColor:
                            col.surfaceVariant, // Set the background color
                        hintText: 'Enter your text',
                        hintStyle: TextStyle(
                            color: col.onSurfaceVariant), // Placeholder text
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                          borderSide: BorderSide.none, // No borders
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0), // Padding inside the text field
                      ),
                    ),
                  ),
                ],
              ),
              // TextField(
              //   controller: nameController,
              //   decoration: const InputDecoration(labelText: 'Name',),
              // ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: col.primary,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: col.onPrimary)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 14),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(_createRoute1(index, selectedLocation));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.location_solid,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Location',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: col.onPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: col.primary,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: col.onPrimary)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 14),
                        child: GestureDetector(
                          onTap: () async {
                            time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              initialEntryMode: TimePickerEntryMode.dial,
                              useRootNavigator: true,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                );
                              },
                            );
                            setState(() {
                              print(time);
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.time_solid,
                                color: col.onPrimary,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                time != null
                                    ? "${time?.hour}:${time?.minute}"
                                    : controller.dataToShow[index].timeMinute !=
                                                -1 &&
                                            controller.dataToShow[index]
                                                    .timeHour !=
                                                -1
                                        ? "Time: ${controller.dataToShow[index].timeHour}:${controller.dataToShow[index].timeMinute}"
                                        : "Add Time",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: col.onPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "Media Volume",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              // Slider(
              //   activeColor: blue,
              //   inactiveColor: grey,
              //   min: 0.0,
              //   max: 100,
              //   label: 'Set volume value',
              //   value: _value,
              //   onChanged: (double value) {
              //     setState(() {
              //       _value = value.roundToDouble();
              //       print(_value);
              //     });
              //   },
              // ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Slider(
                  // activeColor: blue,

                  max: 100,
                  divisions: 100,
                  label: _value.round().toString(),
                  value: _value,
                  onChanged: (double newValue) {
                    setState(() {
                      _value = newValue.roundToDouble();
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "Ringer Volume",
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: col.onSurface),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Slider(
                  max: 100,
                  value: _value,
                  label: _value.round().toString(),
                  onChanged: (double newValue) {
                    setState(() {
                      _value = newValue.roundToDouble();
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Ringer Mode",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                decoration: BoxDecoration(
                  color: col.outlineVariant,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: CupertinoSlidingSegmentedControl<int>(
                  backgroundColor: col.surface,
                  thumbColor: col.primaryContainer,
                  groupValue: selectedRingerMode.toInt(),
                  children: {
                    0: Text('Normal'),
                    1: Text('Vibrate'),
                    2: Text('Silent'),
                  },
                  onValueChanged: (value) {
                    setState(() {
                      selectedRingerMode = value!.toDouble();
                    });
                  },
                ),
              ),
              // RadioListTile<double>(
              //   title: const Text("Normal Mode"),
              //   value: 0.0,
              //   groupValue: selectedRingerMode,
              //   onChanged: (a) {
              //     selectedRingerMode = a!;
              //     setState(() {});
              //   },
              // ),
              // RadioListTile<double>(
              //   title: const Text("Vibrate Mode"),
              //   value: 1.0,
              //   groupValue: selectedRingerMode,
              //   onChanged: (a) {
              //     selectedRingerMode = a!;
              //     setState(() {});
              //   },
              // ),
              // RadioListTile<double>(
              //   title: const Text("Silent Mode"),
              //   value: 2.0,
              //   groupValue: selectedRingerMode,
              //   onChanged: (a) {
              //     selectedRingerMode = a!;
              //     setState(() {});
              //   },
              // ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: col.errorContainer,
                    child: IconButton(
                        onPressed: () {
                          _showDialog(context, index);
                          setState(() {});
                        },
                        icon: const Icon(CupertinoIcons.delete)),
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                      onPressed: () {
                        time = null;
                        Navigator.pop(context, 'Cancel');
                      },
                      child: const Text("Cancel")),
                  const SizedBox(
                    width: 20,
                  ),
                  FilledButton(
                    // style: ElevatedButton.styleFrom(
                    //     backgroundColor: blue, foregroundColor: Colors.white),
                    onPressed: () async {
                      controller.dataToShow.value[index] = Data(
                        ssid: controller.dataToShow.value[index].ssid,
                        name: nameController.text,
                        latitude: lc.latitude.value == 0.0
                            ? controller.dataToShow.value[index].latitude
                            : lc.latitude.value,
                        longitude: lc.longitude.value == 0.0
                            ? controller.dataToShow.value[index].longitude
                            : lc.longitude.value,
                        volumeLevel: _value,
                        ringerMode: selectedRingerMode,
                        timeHour: time?.hour == null ? -1 : time!.hour,
                        timeMinute: time?.minute == null ? -1 : time!.minute,
                      );
                      time = null;
                      await storingData(controller.dataToShow.value);
                      updateListCallback();
                      lc.latitude.value = 0.0;
                      lc.longitude.value = 0.0;
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void updateList() {
    controller.dataToShow.refresh();
    setState(() {});
  }

  void _showDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  controller.dataToShow.value.removeAt(index);
                  storingData(controller.dataToShow.value);
                });

                Navigator.of(context).pop(); // Closes the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    // String appbarname = 'ringerradius';

    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   // You can customize the sensitivity threshold based on your requirement
    //   // print('it is running');
    //   double motionThreshold = 0.01;
    //   double totalAcceleration = event.x.abs() + event.y.abs() + event.z.abs();
    //   if (totalAcceleration > motionThreshold) {
    //     setState(() {
    //       appbarname = 'hello';
    //     });
    //   } else {
    //     print('not enough thresold');
    //   }
    // });

    PerfectVolumeControl.hideUI = true;

    return GetBuilder<LocationController>(builder: (_) {
      LocationController controller = Get.put(LocationController());
      final ColorScheme col = Theme.of(context).colorScheme;
      Map<String, IconData> mp = {
        "0": Icons.volume_up_rounded,
        "1": Icons.vibration_rounded,
        "2": Icons.volume_off_rounded,
      };
      return Scaffold(
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: col.primaryContainer),
                child: Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
              ListTile(
                leading: Icon(Icons.two_wheeler_rounded),
                title: Text('Driving Mode'),
                trailing: Switch(
                    value: controller.drivng.value,
                    onChanged: (bool newval) {
                      setState(() {
                        controller.drivng.value = newval;
                      });
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: col.surfaceVariant,
                          content: Text(
                            'This feature is currently in development',
                            style: TextStyle(color: col.onSurfaceVariant),
                          ),
                          action: SnackBarAction(
                            textColor: col.primary,
                            label: 'OK',
                            onPressed: () {
                              // Code to execute.
                            },
                          ),
                        ),
                      );
                    }),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            appbarname,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          // title: Text(speedMps >= 10.0
          //     ? "Speed ${speedMps.truncate()} KMPS"
          //     : widget.title),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: TextButton.icon(
          //       onPressed: () {
          //         Navigator.push(context, MaterialPageRoute(builder: (context) {
          //           return wifi_ssid();
          //         }));
          //       },
          //       icon: Icon(CupertinoIcons.wifi),
          //       label: Text('Add Wifi'),
          //       style: TextButton.styleFrom(
          //           backgroundColor: Color.fromARGB(255, 190, 224, 169),
          //           foregroundColor: Colors.black),
          //     ),
          //   )
          // ],
        ),
        floatingActionButton: controller.dataToShow.value.isEmpty
            ? null
            : FloatingActionButton(
                // backgroundColor: Color.fromARGB(255, 227, 226, 226),
                child: const Icon(
                  Icons.location_on_outlined,
                  // color: Color.fromARGB(255, 5, 62, 250),
                ),
                onPressed: () async {
                  controller.selectedLocation = LatLng(latitude, longitude);
                  await findName();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const LocationAccess(),
                  //   ),
                  // ).then((value) => () async {});
                  Navigator.of(context).push(_createRoute());
                },
              ),
        body: Center(
          child: controller.dataToShow.value.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: latitude == 0 && longitude == 0
                          ? fetchingData
                          : () async {
                              controller.selectedLocation =
                                  LatLng(latitude, longitude);
                              await findName();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const LocationAccess(),
                              //   ),
                              // );
                              Navigator.of(context).push(_createRoute());
                            },
                      child: fetchingLoader == true
                          ? const Text(
                              "Fetching",
                              style: TextStyle(fontSize: 20),
                            )
                          : latitude == 0 && longitude == 0
                              ? Text(
                                  'Give Location Access',
                                  style: const TextStyle(fontSize: 20),
                                )
                              : Icon(
                                  Icons.add_box_rounded,
                                  color:
                                      const Color.fromARGB(255, 220, 219, 219),
                                  size: 60,
                                ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: controller.dataToShow.value.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _value = controller.dataToShow.value[index].volumeLevel;
                        selectedRingerMode =
                            controller.dataToShow.value[index].ringerMode;
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          useSafeArea: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) =>
                              alertBoxData(index, () => updateList()),
                        );
                        setState(() {});
                      },
                      child: Card(
                        elevation: 0.1,
                        color: col.secondaryContainer.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.red
                                // border: Border(
                                //     bottom: BorderSide(
                                //         width: 0.5,
                                //         color:
                                //             const Color.fromARGB(255, 217, 217, 217))),

                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Color.fromARGB(255, 112, 112, 112)
                                //         .withOpacity(0.5), // Shadow color
                                //     // How wide the shadow should be
                                //     blurRadius:
                                //         0.3, // How blurry the shadow should be
                                //     offset:
                                //         Offset(0, 0.3), // Offset of the shadow (X, Y)
                                //   ),
                                // ],
                                // color: Color.fromARGB(255, 239, 239, 239),
                                // borderRadius: BorderRadius.all(Radius.circular(16),),
                                ),
                            // margin: const EdgeInsets.symmetric(
                            //     horizontal: 10, vertical: 5),
                            // height: 70,
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  maxRadius: 4,
                                  backgroundColor: ((double.parse(latitude.toStringAsFixed(3)) -
                                                      double.parse(controller
                                                          .dataToShow
                                                          .value[index]
                                                          .latitude
                                                          .toStringAsFixed(
                                                              3)) ==
                                                  0) &&
                                              (double.parse(longitude.toStringAsFixed(3)) -
                                                      double.parse(controller
                                                          .dataToShow
                                                          .value[index]
                                                          .longitude
                                                          .toStringAsFixed(
                                                              3)) ==
                                                  0)) ||
                                          (DateTime.now().hour - controller.dataToShow.value[index].timeHour == 0 &&
                                              DateTime.now().minute - controller.dataToShow.value[index].timeMinute == 0)
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  maxRadius: 25,
                                  backgroundColor: col.surface,
                                  child: Text(
                                    controller.dataToShow.value[index].name[0]
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.dataToShow.value[index].name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // SizedBox(
                                    //   height: 5,
                                    // ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: col.primary,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 8),
                                            child: Text(
                                              "Volume ${controller.dataToShow.value[index].volumeLevel.round().toString()}%",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: col.onPrimary),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: col.primary,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Ringer ",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: col.onPrimary),
                                                ),
                                                Icon(
                                                  mp[controller.dataToShow
                                                      .value[index].ringerMode
                                                      .round()
                                                      .toString()],
                                                  color: col.onPrimary,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        CircleAvatar(
                                          maxRadius: 20,
                                          backgroundColor: col.primary,
                                          child: IconButton(
                                              onPressed: () {
                                                _showDialog(context, index);
                                                setState(() {});
                                                // controller.dataToShow.value.removeAt(index);
                                                // storingData(controller.dataToShow.value);
                                              },
                                              icon: Icon(
                                                CupertinoIcons.delete,
                                                color: col.onPrimary,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    });
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LocationAccess(),
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

Route _createRoute1(int index, LatLng selectedLocation) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        LocatioEdit(index: index, selectedLocation: selectedLocation),
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
