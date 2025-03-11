import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // For responsive text sizing
import 'home_page.dart';

/// A widget that displays an onboarding overlay over the [HomePage].
///
/// The overlay slides up from the bottom and covers 70% of the screen height,
/// providing users with an introduction to the app's features. The user can dismiss
/// the onboarding screen by tapping the "Get Started" button.
class HomeWithOnboarding extends StatefulWidget {
  const HomeWithOnboarding({Key? key}) : super(key: key);

  @override
  State<HomeWithOnboarding> createState() => _HomeWithOnboardingState();
}

class _HomeWithOnboardingState extends State<HomeWithOnboarding>
    with SingleTickerProviderStateMixin {
  // Controls whether the onboarding overlay is visible.
  bool _showOnboarding = true;

  // Animation controller for the slide transition.
  late final AnimationController _animationController;

  // Slide animation for the onboarding overlay.
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a 500ms duration.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Define the slide animation: it starts off-screen (Offset(0, 1)) and ends at its normal position (Offset(0, 0)).
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start below the screen
      end: const Offset(0, 0),   // End at the normal position
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Begin the slide-up animation when the widget is initialized.
    _animationController.forward();
  }

  /// Closes the onboarding overlay by reversing the slide animation.
  void _closeOnboarding() {
    _animationController.reverse().then((_) {
      setState(() {
        _showOnboarding = false;
      });
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller when the widget is removed.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main home page (which contains tabs for Search & Generate).
        const HomePage(),

        // Display the onboarding overlay only if _showOnboarding is true.
        if (_showOnboarding)
          Positioned.fill(
            child: Container(
              // Semi-transparent black overlay.
              color: Colors.black.withOpacity(0.5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    // The overlay covers 70% of the screen height.
                    height: MediaQuery.of(context).size.height * 0.7,
                    // Fixed padding for consistent spacing.
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // Rounded top corners.
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        // Soft shadow for depth.
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    // The main content of the onboarding overlay.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Icon at the top.
                        const Icon(
                          Icons.image_search_rounded,
                          size: 80,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 40),

                        // App Title using AutoSizeText for responsive text scaling.
                        const AutoSizeText(
                          "Welcome to Image Search & Generator",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),

                        // Expanded section for listing app features.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureRow(
                                    Icons.search, "Search high-quality images easily"),
                                const SizedBox(height: 20),
                                _buildFeatureRow(Icons.auto_awesome,
                                    "Generate AI-powered images instantly"),
                                const SizedBox(height: 20),
                                _buildFeatureRow(
                                    Icons.sync, "Infinite scrolling & real-time search"),
                                const SizedBox(height: 20),
                                _buildFeatureRow(
                                    Icons.bookmark, "View and save your favorite images"),
                              ],
                            ),
                          ),
                        ),

                        // "Get Started" button that dismisses the onboarding overlay.
                        ElevatedButton(
                          onPressed: _closeOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const AutoSizeText(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                          ),
                        ),

                        const SizedBox(height: 100), // Extra spacing at the bottom.
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a row with an [icon] and descriptive [text] for a feature.
  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: AutoSizeText(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              decoration: TextDecoration.none,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
