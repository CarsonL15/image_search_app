import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Displays a full-screen preview of the image specified by [imageUrl] using a fade
/// transition with a blurred background. The [imageUrl] is also used as a unique
/// hero tag for smooth transitions.
///
/// Tapping anywhere (or using the back arrow) dismisses the preview.
///
/// Returns a [Future] that completes when the preview is dismissed.
Future<void> showFullScreenImage(BuildContext context, String imageUrl) {
  return Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FadeTransition(
        opacity: animation,
        child: ImagePreviewPage(
          imageUrl: imageUrl,
          heroTag: imageUrl, // using imageUrl as a unique hero tag
        ),
      );
    },
  ));
}

/// A full-screen page that displays an image with a blurred background and a large
/// "Save Image" button. The image is shown using a Hero widget for smooth transitions.
///
/// Tapping the back arrow or anywhere on the background will dismiss the preview.
class ImagePreviewPage extends StatelessWidget {
  /// The URL of the image to display.
  final String imageUrl;

  /// A unique tag used for the Hero animation.
  final String heroTag;

  /// Creates an instance of [ImagePreviewPage].
  const ImagePreviewPage({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
  }) : super(key: key);

  /// Downloads the image from [imageUrl] to a temporary file and saves it to the gallery.
  ///
  /// Displays a [SnackBar] indicating success or failure.
  Future<void> _saveImage(BuildContext context) async {
    try {
      // Download image bytes
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get a temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/temp_image.png';
        final File file = File(filePath);
        // Write image bytes to the file
        await file.writeAsBytes(response.bodyBytes);
        // Save the file to gallery using GallerySaver
        await GallerySaver.saveImage(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show blurred background
      body: Stack(
        children: [
          // Blurred background overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Full-screen image with Hero animation and save button
          SafeArea(
            child: Column(
              children: [
                // Top bar with a back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Large "Save Image" button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveImage(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Image',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
