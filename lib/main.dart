import 'package:flutter/material.dart';
import 'package:mlkitfirebasefeatures/screen/language_translation.dart';
import 'package:mlkitfirebasefeatures/widget/selection_bottom_sheet.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: InkWell(
                child: Text('Detect Food'),
                onTap: () => showDetectSelectionBottomSheet(context),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Text('Translate'),
                onTap: () => LanguageTranslation.navigate(context),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Text('Others'),
                onTap: () => showDetectSelectionBottomSheet(context, others: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
