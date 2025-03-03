import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<Map<String, dynamic>?> getCoordinates(String destination) async {
    final String apiUrl =
        "https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(destination)}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            "lat": double.parse(data[0]["lat"]),
            "lon": double.parse(data[0]["lon"]),
          };
        }
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
    return null;
  }
}
