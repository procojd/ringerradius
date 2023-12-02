import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location_app/logic/background_logic.dart';
import 'package:location_app/ui/splashcreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// void backgroundFetchHeadlessTask() async {
//   await checkWifiStatus();
// }

// Future<void> checkWifiStatus() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//   if (connectivityResult == ConnectivityResult.wifi) {
//     setvolumewifi();
//   } else {
//     // Wi-Fi is not available, handle the scenario accordingly
//   }
// }

// void initBackgroundFetch() {
//   BackgroundFetch.configure(
//       BackgroundFetchConfig(
//         minimumFetchInterval: 2, // Minimum fetch interval in minutes
//         stopOnTerminate: false,
//         enableHeadless: true,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresStorageNotLow: false,
//       ), (String taskId) async {
//     // This callback will be called when the app is in the background
//     await checkWifiStatus();
//     BackgroundFetch.finish(taskId);
//   });
//   BackgroundFetch.scheduleTask(TaskConfig(
//     taskId: "com.example.background_wifi_check",
//     delay: 1,
//     periodic: true,
//   ));
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
// static final _defaultLightColorScheme = ColorScheme.fromSeed(
//       seedColor: Color.fromARGB(255, 248, 134, 3),brightness: Brightness.light);

//   static final _defaultDarkColorScheme = ColorScheme.fromSeed(
//       seedColor: Color.fromARGB(255, 248, 134, 3),brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orangeAccent,
              brightness: Brightness.light),
          useMaterial3: true,
          fontFamily: 'SF Pro Display'),

      themeMode: ThemeMode.system,
      
      darkTheme: ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orangeAccent,
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const splashscreen(),
    );
  }
}
