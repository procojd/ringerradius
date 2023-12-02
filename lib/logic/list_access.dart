import 'package:location_app/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

gettingData() async {
  List<Data> empty = [];
  final SharedPreferences prefs = await _prefs;
  prefs.reload();
  final String? musicsString = prefs.getString("Data");
  if (musicsString != null) {
    var dataToShow = Data.decode(musicsString);
    print(dataToShow);
    return dataToShow;
  }
  return empty;
}

storingData(dataToStore) async {
  final SharedPreferences prefs = await _prefs;
  final String encodedData = Data.encode(dataToStore);
  print(dataToStore);
  prefs.remove("Data");
  prefs.setString("Data", encodedData);
}
