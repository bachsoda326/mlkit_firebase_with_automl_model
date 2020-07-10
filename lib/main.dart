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
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/food.jpg'),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    'Detect Food',
                    style: TextStyle(fontSize: 30),
                  )),
                ),
                onTap: () => showDetectSelectionBottomSheet(context),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/translate.jpg'),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    'Translate',
                    style: TextStyle(fontSize: 30),
                  )),
                ),
                onTap: () => LanguageTranslation.navigate(context),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/other.jpg'),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    'Others',
                    style: TextStyle(fontSize: 30),
                  )),
                ),
                onTap: () => showDetectSelectionBottomSheet(context, others: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
