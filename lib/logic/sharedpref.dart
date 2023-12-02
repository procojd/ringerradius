import 'package:get/get.dart';
import 'package:location_app/controller/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

LocationController controller = Get.put(LocationController());
void getpref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? repeat = prefs.getBool('onboarding');
  controller.onboarding.value = repeat!;
}

void setpref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding', true);
}
