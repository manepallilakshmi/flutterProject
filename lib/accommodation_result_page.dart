import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AccommodationResultPage extends StatefulWidget {
  final String destination;
  const AccommodationResultPage({super.key, required this.destination});

  @override
  AccommodationResultPageState createState() => AccommodationResultPageState();
}

class AccommodationResultPageState extends State<AccommodationResultPage> {
  List<dynamic> hotels = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    final apiKey = '008fcbe8bamsh16eb7e2e745eb79p1df7dfjsn774fe5f0bfef'; // Your API Key
    final url =
        "https://hotels-com-provider.p.rapidapi.com/v2/regions?query=${widget.destination}&domain=AR&locale=es_AR";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-rapidapi-host': 'hotels-com-provider.p.rapidapi.com',
        'x-rapidapi-key': apiKey,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          setState(() {
            hotels = responseData['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error occurred: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hotels in ${widget.destination}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load hotels"))
              : ListView.builder(
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];

                    // Extract hotel details from the API response
                    final String hotelName = hotel['regionNames']?['displayName'] ?? 'No name available';
                    final String hotelImageUrl = hotel['imageUrl'] ?? 'https://via.placeholder.com/150'; // Placeholder image if none found
                    final String hotelPrice = hotel['price']?.toString() ?? 'Price not available';
                    final String bookingUrl = hotel['bookingUrl'] ?? 'https://www.booking.com'; // Placeholder booking link

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(hotelImageUrl, width: 80, height: 80, fit: BoxFit.cover),
                        title: Text(hotelName),
                        subtitle: Text("Price: \$${hotelPrice} per night"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (bookingUrl.isNotEmpty) {
                              launchUrl(Uri.parse(bookingUrl));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Booking link not available")),
                              );
                            }
                          },
                          child: const Text("Book Now"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
