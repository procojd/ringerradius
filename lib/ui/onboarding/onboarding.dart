import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'package:location_app/logic/sharedpref.dart';
import 'package:location_app/ui/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class onboarding_1 extends StatefulWidget {
  const onboarding_1({super.key});

  @override
  State<onboarding_1> createState() => _onboarding_1State();
}

class _onboarding_1State extends State<onboarding_1> {
  bool isanimate = false;
  int _count = 0;
  Color _color = Colors.green;
  late final SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    getpref();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _color = Colors.white;

        // isanimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: AnimatedContainer(
        height: height,
        width: width,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: isanimate ? Alignment.topLeft : Alignment.topRight,
            radius: 2.0,
            colors: isanimate
                ? [
                    const Color.fromARGB(255, 3, 91, 244),
                    Colors.lightBlue,
                    const Color.fromARGB(255, 121, 188, 220),
                    Color.fromARGB(255, 234, 234, 234)
                    // Colors.white,
                  ]
                : [
                    Color.fromARGB(255, 91, 3, 244),
                    const Color.fromARGB(255, 107, 3, 244),
                    Color.fromARGB(255, 176, 121, 220),
                    const Color.fromARGB(255, 235, 235, 235),
                  ],
          ),
        ),
        child: Column(children: [
          SizedBox(
            height: height * 0.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: isanimate ? height * 0.1 + 50 : height * 0.1,
                  left: isanimate ? (width / 2 - 300) : (width / 2 - 100),
                  child: AnimatedOpacity(
                    opacity: isanimate ? 0.0 : 0.5,
                    duration: Duration(milliseconds: 500),
                    child: Container(
                        // color: Colors.white,
                        width: width,
                        // height: height * 0.5,
                        // color: Colors.white,
                        child: Icon(
                          CupertinoIcons.building_2_fill,
                          size: 250,
                        )),
                  ),
                  duration: Duration(milliseconds: 1000),
                ),
                AnimatedPositioned(
                  curve: Curves.easeInOut,
                  top: isanimate ? height * 0.1 + 50 : height * 0.1,
                  left: isanimate ? (width / 2 - 300) : (width / 2 - 100),
                  child: AnimatedOpacity(
                    opacity: isanimate ? 0.5 : 0.0,
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                        // color: Colors.white,
                        width: width,
                        // height: height * 0.5,
                        // color: Colors.white,
                        child: Icon(
                          CupertinoIcons.home,
                          size: 250,
                        )),
                  ),
                  duration: Duration(milliseconds: 1000),
                ),
                AnimatedPositioned(
                  curve: Curves.bounceInOut,
                  top: height * 0.1,

                  // top: isanimate? height*0.2:height*0.2+50,
                  // left: isanimate? width/2-200:(width/2-200),
                  child: Container(
                      // color: Colors.white,
                      width: width,
                      // height: height * 0.5,
                      // color: Colors.white,
                      child: Center(
                          child: Image.asset(
                        'lib/ui/ji.png',
                        fit: BoxFit.fill,
                      ))),
                  duration: Duration(milliseconds: 500),
                ),
                AnimatedPositioned(
                  curve: Curves.bounceInOut,
                  bottom: height * 0.15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.2,
                              color: const Color.fromARGB(255, 167, 167, 167)),
                          borderRadius: BorderRadius.circular(40),
                          color: Color.fromARGB(44, 0, 0, 0),
                        ),
                        child: Center(
                          child: Icon(
                            isanimate
                                ? CupertinoIcons.volume_up
                                : CupertinoIcons.volume_off,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  duration: Duration(milliseconds: 500),
                ),
              ],
            ),
          ),
          FadeInUp(
              from: 50,
              child: Text(
                !isanimate ? 'Welcome to RingerRadius' : 'Just Relax',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                textAlign: TextAlign.center,
              )),
          FadeInUp(
            from: 50,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
              child: Text(
                !isanimate
                    ? '\nSay goodbye to volume adjustments – let your phone dance to the rhythm of your life!\n \n Thanks to the magic of location-based automation'
                    : 'Let RingerRadius adjust your device settings as you move between locations or \n connect to trusted Wi-Fi networks',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Spacer(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 210, 210, 210),
                  backgroundColor: Colors.black),
              onPressed: () {
                setState((){
                  isanimate = true;
                  _count++;
                  if (_count == 2) {
                    setpref();
                    Get.off(MyHomePage(title: 'Location_App'));

                    // Prints after 1 second.
                  }
                });
              },
              child: isanimate
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 20),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 20),
                      child: Text(
                        'Next',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 16),
                      ),
                    )),
          SizedBox(
            height: height * 0.05,
          ),
        ]),
      ),
    );
  }
}
