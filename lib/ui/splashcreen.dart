import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location_app/controller/location_controller.dart';
import 'package:location_app/logic/sharedpref.dart';
import 'package:location_app/ui/homepage.dart';
import 'package:location_app/ui/onboarding/onboarding.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen>
    with SingleTickerProviderStateMixin {
  LocationController controller1 = Get.put(LocationController());
  bool istrue = false;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    getpref();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )
      ..forward()
      ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        istrue = true;
      }); // Prints after 1 second.
    });

    //getting preference according to onboarding screen
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (controller1.onboarding.value == true) {
        Get.off(MyHomePage(title: 'Location_App'));
      } else {
        Get.off(onboarding_1());
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: istrue?Color.fromARGB(255, 28, 55, 50):Colors.white,
      body: Stack(
        children: [
          Center(
            child: AnimatedIcon(
              icon: AnimatedIcons.search_ellipsis,
              color: Color.fromARGB(255, 253, 102, 2),
              progress: animation,
              size: 72.0,
              semanticLabel: 'Show menu',
            ),
          ),
          AnimatedScale(
            duration: const Duration(seconds: 1),
            scale: istrue ? 3 : 0,
            curve: Curves.easeOutCubic,
            child: CircleAvatar(
              maxRadius: MediaQuery.sizeOf(context).height,
              backgroundColor: Color.fromARGB(255, 253, 102, 2),
            ),
          ),
          Center(
            child: AnimatedScale(
              duration: const Duration(seconds: 1),
              scale: istrue ? 3 : 0,
              curve: Curves.easeOutCubic,
              child: const Icon(
                CupertinoIcons.location_solid,
                color: Color.fromARGB(255, 235, 255, 248),
              ),
              // child: Text(
              //   'Location_App',
              //   style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       color: Color.fromARGB(255, 224, 255, 243)),
              // )
            ),
          )
        ],
      ),
    );
  }
}
