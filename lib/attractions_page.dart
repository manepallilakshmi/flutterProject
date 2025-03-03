import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttractionsPage extends StatefulWidget {
  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  final TextEditingController _destinationController = TextEditingController();
  List attractions = [];

  Future<void> _fetchAttractions() async {
    final response = await http.get(Uri.parse('https://api.example.com/attractions?destination=${_destinationController.text}'));
    if (response.statusCode == 200) {
      setState(() {
        attractions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load attractions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tourist Attractions')),
      body: Column(
        children: [
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(labelText: 'Enter Destination'),
          ),
          ElevatedButton(onPressed: _fetchAttractions, child: Text('Search Attractions')),
          ListView.builder(
            shrinkWrap: true,
            itemCount: attractions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(attractions[index]['name']),
                subtitle: Text(attractions[index]['details']),
              );
            },
          ),
        ],
      ),
    );
  }
}
