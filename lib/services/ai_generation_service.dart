import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A service for generating AI images using OpenAI's API.
///
/// This service provides a static method to generate images based on a prompt.
/// In case of errors (such as rate limits or connection issues), it displays an
/// error dialog to the user and returns an empty list.
class AiGenerationService {
  /// Your OpenAI API key.
  static const String _apiKey =
      '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';

  /// The base URL for the OpenAI image generations endpoint.
  static const String _apiUrl = 'https://api.openai.com/v1/images/generations';

  /// Generates images for the given [prompt] by calling the OpenAI API.
  ///
  /// The [context] is used to display error dialogs in case of failures.
  ///
  /// Returns a [Future] that resolves to a list of image URLs if successful;
  /// otherwise, it returns an empty list.
  static Future<List<String>> generateImages(
      BuildContext context, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': "dall-e-2",
          'prompt': prompt,
          'n': 4,
          'size': '512x512',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> imagesData = data['data'];
        return imagesData
            .map<String>((dynamic item) => item['url'] as String)
            .toList();
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        if (errorBody['error']['code'] == 'rate_limit_exceeded') {
          _showErrorDialog(
              context, 'Rate limit exceeded. Please wait a minute and try again.');
          return [];
        }
        _showErrorDialog(
            context, 'Failed to generate images: ${errorBody['error']['message']}');
        return [];
      }
    } catch (e) {
      _showErrorDialog(context, 'Error contacting OpenAI. Please try again.');
      return [];
    }
  }

  /// Displays an error dialog with the given [message].
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Oops! Something went wrong'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
