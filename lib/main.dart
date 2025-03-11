import 'package:flutter/material.dart';
import 'pages/home_with_onboarding.dart';

/// The entry point for the Image Explorer app.
///
/// This application offers image search and AI-generated images along with an onboarding screen.
void main() {
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
