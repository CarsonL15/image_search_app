import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv package
import 'pages/home_with_onboarding.dart';

/// The entry point for the Image Explorer app.
///
/// This application offers image search and AI-generated images along with an onboarding screen.
/// Environment variables (including API keys) are loaded from the .env file in the project root.
Future<void> main() async {
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  runApp(const ImageSearchApp());
}

/// The root widget of the Image Explorer application.
class ImageSearchApp extends StatelessWidget {
  /// Creates an instance of [ImageSearchApp].
  const ImageSearchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeWithOnboarding(), // Home page with onboarding overlay
    );
  }
}
