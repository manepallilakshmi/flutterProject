import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get rapidApiKey => dotenv.env['RAPID_API_KEY'] ?? '';
}
