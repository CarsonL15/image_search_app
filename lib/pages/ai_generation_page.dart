import 'package:flutter/material.dart';
import '../services/ai_generation_service.dart';
import 'image_preview_page.dart'; // Import the preview helper

/// A page that allows users to generate AI-powered images based on a prompt.
///
/// The user enters a prompt into the text field, and tapping the send icon
/// triggers image generation. Generated images are displayed in a grid; tapping
/// an image opens a full-screen preview.
class AiGenerationPage extends StatefulWidget {
  /// Creates an instance of [AiGenerationPage].
  const AiGenerationPage({Key? key}) : super(key: key);

  @override
  State<AiGenerationPage> createState() => _AiGenerationPageState();
}

class _AiGenerationPageState extends State<AiGenerationPage> {
  /// Controller for the prompt input field.
  final TextEditingController _promptController = TextEditingController();

  /// List to store generated image URLs.
  List<String> _generatedImages = [];

  /// Indicates whether the image generation process is ongoing.
  bool _isGenerating = false;

  /// Generates images based on the user's prompt.
  ///
  /// If the prompt is empty, no request is made. Otherwise, the method calls
  /// [AiGenerationService.generateImages] and updates the UI accordingly.
  Future<void> _generateImages() async {
    final String prompt = _promptController.text;
    if (prompt.isEmpty) return;
    setState(() {
      _isGenerating = true;
    });
    try {
      final List<String> images =
          await AiGenerationService.generateImages(context, prompt);
      setState(() {
        _generatedImages = images;
      });
    } catch (e) {
      // Display an error message if image generation fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating images: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// Opens the full-screen image preview for the given [imageUrl].
  void _openImagePreview(String imageUrl) {
    showFullScreenImage(context, imageUrl);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Prompt input field with a send button.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _promptController,
            decoration: InputDecoration(
              hintText: 'Enter prompt for image generation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              // Send button is displayed as the suffix icon.
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isGenerating ? null : _generateImages,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isGenerating
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Generating images...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : _generatedImages.isEmpty
                  ? const Center(
                      child: Text(
                        'Enter a prompt and press send to generate images',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Display images in a 2x2 grid.
                        childAspectRatio: 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _generatedImages.length,
                      itemBuilder: (context, index) {
                        final String imageUrl = _generatedImages[index];
                        return GestureDetector(
                          onTap: () => _openImagePreview(imageUrl),
                          child: Hero(
                            tag: imageUrl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
        // "Regenerate" button appears only when images are present and not generating.
        if (_generatedImages.isNotEmpty && !_isGenerating)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _generateImages,
              child: const Text('Regenerate'),
            ),
          ),
      ],
    );
  }
}
