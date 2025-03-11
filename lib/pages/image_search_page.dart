import 'dart:async';
import 'package:flutter/material.dart';
import '../services/image_search_service.dart';
import 'image_preview_page.dart'; // Import the preview helper

/// A page that allows users to search for images via the Pixabay API.
/// 
/// Users can enter a search query, and images will be displayed in a grid.
/// Tapping an image opens a full-screen preview.
class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({Key? key}) : super(key: key);

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  List<String> _images = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Listens for changes in the search input and triggers a debounced search.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_query != _controller.text) {
        setState(() {
          _query = _controller.text;
          _currentPage = 1;
          _images.clear();
          _hasMore = true;
        });
        if (_query.isNotEmpty) {
          _fetchImages();
        }
      }
    });
  }

  /// Listens for scrolling to trigger loading of more images.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore &&
        _query.isNotEmpty) {
      _currentPage++;
      _fetchImages();
    }
  }

  /// Fetches images using [ImageSearchService] based on the current query and page.
  Future<void> _fetchImages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<String> newImages =
          await ImageSearchService.fetchImages(_query, _currentPage);
      setState(() {
        if (newImages.length < 10) {
          _hasMore = false;
        }
        _images.addAll(newImages);
      });
    } catch (e) {
      debugPrint('Error fetching images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Opens the full-screen image preview for the given [imageUrl].
  void _openImagePreview(String imageUrl) {
    showFullScreenImage(context, imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search for images...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _images.clear();
                          _query = '';
                          _hasMore = true;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _images.isEmpty && !_isLoading
              ? const Center(
                  child: Text(
                    'Enter a search to find images',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _images.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _images.length) {
                      final String imageUrl = _images[index];
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
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
        ),
      ],
    );
  }
}
