import 'package:flutter/material.dart';
import 'package:mlkitfirebasefeatures/screen/language_translation.dart';
import 'package:mlkitfirebasefeatures/widget/option_button.dart';
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
      // appBar: AppBar(
      //   title: Text('Home Screen'),
      // ),
      body: Container(
        color: Color(0xFF333561),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Expanded(
              //   child: Container(
              //     padding: EdgeInsets.symmetric(vertical: 2),
              //     child: InkWell(
              //       child: Stack(
              //         children: [
              //           Row(
              //             children: [
              //               Expanded(
              //                 flex: 1,
              //                 child: SizedBox(
              //                   width: 24,
              //                 ),
              //               ),
              //               Expanded(
              //                 flex: 4,
              //                 child: Container(
              //                   width: MediaQuery.of(context).size.width,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(6),
              //                     color: Colors.purple[300],
              //                     image: DecorationImage(
              //                       fit: BoxFit.fill,
              //                       colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
              //                       image: AssetImage('assets/images/food.jpg'),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //           Align(
              //             alignment: Alignment.centerLeft,
              //             child: Text(
              //               '   DETECT FOOD',
              //               style: TextStyle(fontSize: 24, color: Colors.white),
              //             ),
              //           ),
              //         ],
              //       ),
              //       onTap: () => showDetectSelectionBottomSheet(context),
              //     ),
              //   ),
              // ),
              // Expanded(
              //   child: InkWell(
              //     child: Container(
              //       width: MediaQuery.of(context).size.width,
              //       decoration: BoxDecoration(
              //         image: DecorationImage(
              //           fit: BoxFit.fill,
              //           image: AssetImage('assets/images/translate.jpg'),
              //         ),
              //       ),
              //       child: Center(
              //           child: Text(
              //         'Translate',
              //         style: TextStyle(fontSize: 24),
              //       )),
              //     ),
              //     onTap: () => LanguageTranslation.navigate(context),
              //   ),
              // ),
              // Expanded(
              //   child: InkWell(
              //     child: Container(
              //       width: MediaQuery.of(context).size.width,
              //       decoration: BoxDecoration(
              //         image: DecorationImage(
              //           fit: BoxFit.fill,
              //           image: AssetImage('assets/images/other.jpg'),
              //         ),
              //       ),
              //       child: Center(
              //           child: Text(
              //         'Others',
              //         style: TextStyle(fontSize: 24),
              //       )),
              //     ),
              //     onTap: () => showDetectSelectionBottomSheet(context, others: true),
              //   ),
              // ),
              OptionButton(
                title: 'DETECT FOOD',
                firstColor: Color(0xff896dd2),
                secondColor: Color(0xff696bb5),
                thirdColor: Color(0xff4d679a),
                image: 'assets/images/food.jpg',
                callback: () => showDetectSelectionBottomSheet(context),
              ),
              OptionButton(
                title: 'TRANSLATE',
                firstColor: Color(0xfff1666b),
                secondColor: Color(0xffce698e),
                thirdColor: Color(0xff936dce),
                image: 'assets/images/translate.png',
                callback: () => LanguageTranslation.navigate(context),
              ),
              OptionButton(
                title: 'OTHERS',
                firstColor: Color(0xfff1a456),
                secondColor: Color(0xfff5815d),
                thirdColor: Color(0xfff76662),
                image: 'assets/images/other.jpg',
                callback: () => showDetectSelectionBottomSheet(context, others: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
