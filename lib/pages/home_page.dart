import 'package:flutter/material.dart';
import 'image_search_page.dart';
import 'ai_generation_page.dart';

/// The main home page for the Image Search & Generation app.
///
/// This page uses a [TabBar] to allow users to switch between the image search
/// functionality and the AI generation functionality.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] widget.
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Controller for managing tab selection animations.
  late final TabController _tabController;

  // List of tabs displayed in the TabBar.
  final List<Tab> _tabs = const [
    Tab(text: 'Search'),
    Tab(text: 'Generate'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the length of the tabs.
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController when the widget is removed.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Search & Generation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
        ),
      ),
      // The body contains a TabBarView that displays each page.
      body: TabBarView(
        controller: _tabController,
        children: const [
          ImageSearchPage(),
          AiGenerationPage(),
        ],
      ),
    );
  }
}
