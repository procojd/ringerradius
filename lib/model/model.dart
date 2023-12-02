import 'dart:convert';

class Data {
  final double latitude, longitude, volumeLevel, ringerMode;
  final int timeHour, timeMinute;
  final String name;
  final String ssid;

  Data(
    {
    required this.ssid, 
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.volumeLevel,
    required this.ringerMode,
    required this.timeHour,
    required this.timeMinute, 
  });

  factory Data.fromJson(Map<String, dynamic> jsonData) {
    return Data(
      ssid: jsonData['ssid'],
      name: jsonData['name'],
      latitude: jsonData['latitude'],
      longitude: jsonData['longitude'],
      volumeLevel: jsonData['volumeLevel'],
      ringerMode: jsonData['ringerMode'],
      timeHour: jsonData['timeHour'],
      timeMinute: jsonData['timeMinute'],
    );
  }

  static Map<String, dynamic> toMap(Data data) => {
        'ssid':data.ssid,
        'name': data.name,
        'latitude': data.latitude,
        'longitude': data.longitude,
        'volumeLevel': data.volumeLevel,
        'ringerMode': data.ringerMode,
        'timeHour': data.timeHour,
        'timeMinute': data.timeMinute,
      };

  static String encode(List<Data> datas) => json.encode(
        datas.map<Map<String, dynamic>>((data) => Data.toMap(data)).toList(),
      );

  static List<Data> decode(String datas) =>
      (json.decode(datas) as List<dynamic>)
          .map<Data>((item) => Data.fromJson(item))
          .toList();
}
