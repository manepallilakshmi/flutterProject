import 'package:flutter/material.dart';
import 'map_page.dart';
import 'accommodation_page.dart';
import 'food_page.dart';
import 'attractions_page.dart';
import 'login_page.dart'; // Ensure correct filename

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage(onTap: null)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Welcome to Travel Guide",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Open Map
            ElevatedButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) =>  MapPage())),
              child: const Text('Open Map'),
            ),
            const SizedBox(height: 10),

            // Accommodation
            ElevatedButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) =>  const AccommodationPage())),
              child: const Text('View Accommodation'),
            ),
            const SizedBox(height: 10),

            // Food Ordering
            ElevatedButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => FoodPage())),
              child: const Text('Order Food'),
            ),
            const SizedBox(height: 10),

            // Attractions
            ElevatedButton(
              onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => AttractionsPage())),
              child: const Text('Tourist Attractions'),
            ),
          ],
        ),
      ),
    );
  }
}
