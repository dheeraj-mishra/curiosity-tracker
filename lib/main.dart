import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curiosity Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: SearchTrackerScreen(),
    );
  }
}

class SearchTrackerScreen extends StatefulWidget {
  @override
  _SearchTrackerScreenState createState() => _SearchTrackerScreenState();
}

class _SearchTrackerScreenState extends State<SearchTrackerScreen> {
  TextEditingController _searchController = TextEditingController();
  int _searchCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSearchCount();
  }

  // Load the number of searches made today
  _loadSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T')[0];
    int count = prefs.getInt(today) ?? 0;
    setState(() {
      _searchCount = count;
    });
  }

  // Increment the search count and store it locally
  _incrementSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T')[0];
    int count = prefs.getInt(today) ?? 0;
    count += 1;
    await prefs.setInt(today, count);

    setState(() {
      _searchCount = count;
    });
  }

  // Navigate to the web view to perform search
  _performSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      _incrementSearchCount();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(searchQuery: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Curiosity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'search query',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: Text('Search'),
            ),
            SizedBox(height: 24),
            Text(
              'Searches made today: $_searchCount',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String searchQuery;

  WebViewScreen({required this.searchQuery});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Android-specific initialization for WebView
    // if (WebView.platform == null) {
    //   WebView.platform = SurfaceAndroidWebView(); // Ensure this line is included
    // }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(widget.searchQuery)}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
