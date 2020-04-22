import 'package:flutter/material.dart';
import 'package:mlkitfirebasefeatures/camera_preview_scanner.dart';
import 'package:mlkitfirebasefeatures/picture_scanner.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/': (context) => _HomeScreen(),
        '/$PictureScanner': (context) => PictureScanner(),
        '/$CameraPreviewScanner': (context) => CameraPreviewScanner(),
      },
    ),
  );
}

class _HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<_HomeScreen> {
  static final List<String> widgetNames = [
    '$PictureScanner',
    '$CameraPreviewScanner',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: ListView.builder(
        itemCount: widgetNames.length,
        itemBuilder: (context, index) {
          final String widgetName = widgetNames[index];

          return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text(widgetName),
              onTap: () => Navigator.pushNamed(context, '/$widgetName'),
            ),
          );
        },
      ),
    );
  }
}
