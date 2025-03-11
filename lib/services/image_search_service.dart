import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// A service that fetches images from the Pixabay API based on a search query.
///
/// This class uses the Pixabay API with SafeSearch enabled and returns a list
/// of image URLs from the search results.
class ImageSearchService {
  /// Your Pixabay API key loaded from the .env file.
  static final String _apiKey = dotenv.env['PIXABAY_API_KEY'] ?? '';

  /// The base URL for the Pixabay API.
  static const String _baseUrl = 'https://pixabay.com/api/';

  /// Fetches a list of image URLs for the given [query] and [page].
  ///
  /// The [query] parameter is the search term, and [page] indicates the
  /// pagination page number (with 10 results per page).
  ///
  /// Returns a [Future] that resolves to a list of image URLs as [String]s.
  ///
  /// Throws an [Exception] if the API request fails.
  static Future<List<String>> fetchImages(String query, int page) async {
    final url = Uri.parse(
      '$_baseUrl?key=$_apiKey&q=${Uri.encodeComponent(query)}&image_type=photo&page=$page&per_page=10&safesearch=true',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> hits = jsonData['hits'];
      // Convert hits to a list of image URLs.
      return hits.map<String>((dynamic hit) => hit['webformatURL'] as String).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }
}
