import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_keys.dart';

class HotelService {
  static Future<List<Map<String, dynamic>>> getHotels(double lat, double lon) async {
    final String apiKey = ApiKeys.rapidApiKey;
    if (apiKey.isEmpty) return [];

    final String apiUrl =
        "https://booking-com.p.rapidapi.com/v1/hotels/search-by-coordinates?"
        "latitude=$lat&longitude=$lon&locale=en-gb&checkin_date=2025-03-10&checkout_date=2025-03-11"
        "&adults_number=2&order_by=popularity&filter_by_currency=USD&units=metric";

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        "X-RapidAPI-Key": apiKey,
        "X-RapidAPI-Host": "booking-com.p.rapidapi.com",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["result"] == null || data["result"].isEmpty) return [];

        return (data["result"] as List).map((hotel) {
          return {
            "name": hotel["hotel_name"] ?? "Unnamed Hotel",
            "address": hotel["address"] ?? "No address available",
            "price": hotel["price_breakdown"]?["gross_price"]?["value"]?.toString() ?? "N/A",
            "currency": hotel["price_breakdown"]?["gross_price"]?["currency"] ?? "USD",
            "imageUrl": hotel["main_photo_url"] ?? "",
            "bookingUrl": hotel["url"] ?? "",
                 };
        }).toList();
      }
    } catch (e) {
      print("Error fetching hotel list: $e");
    }
    return [];
  }
}
