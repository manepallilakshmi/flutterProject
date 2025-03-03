import 'package:flutter/material.dart';
import 'accommodation_result_page.dart'; // Navigates to this page for hotel details

class AccommodationPage extends StatefulWidget {
  const AccommodationPage({super.key});

  @override
  _AccommodationPageState createState() => _AccommodationPageState();
}

class _AccommodationPageState extends State<AccommodationPage> {
  String destination = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accommodation Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => destination = value.trim()),
              decoration: const InputDecoration(
                labelText: 'Enter Destination',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (destination.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccommodationResultPage(destination: destination),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a destination")),
                  );
                }
              },
              child: const Text('Find Accommodation'),
            ),
          ],
        ),
      ),
    );
  }
}
