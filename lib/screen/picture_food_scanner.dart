import 'dart:async';
import 'dart:io';
import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkitfirebasefeatures/screen/language_translation.dart';

class FoodPictureScanner extends StatefulWidget {
  static Future<dynamic> navigate(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FoodPictureScanner(),
    ));
  }

  @override
  State<StatefulWidget> createState() {
    return _FoodPictureScannerState();
  }
}

class _FoodPictureScannerState extends State<FoodPictureScanner> {
  File _imgFile;
  dynamic _scanResults;
  bool _isDetecting = false;

  final VisionEdgeImageLabeler _visionEdgeImageLabeler = FirebaseVision.instance.visionEdgeImageLabeler('model', ModelLocation.Local);

  // Get img from gallery/camera and scan
  Future<void> _getAndScanImg(ImageSource source) async {
    _scanResults = null;
    final imgFile = await ImagePicker.pickImage(source: source);

    if (imgFile != null) {
      setState(() {
        _imgFile = imgFile;
      });
    }
  }

  // Scan img
  Future<void> _scanImg(File imgFile) async {
    setState(() {
      _isDetecting = true;
      _scanResults = null;
    });

    final FirebaseVisionImage visionImg = FirebaseVisionImage.fromFile(imgFile);
    dynamic results = await _visionEdgeImageLabeler.processImage(visionImg);

    setState(() {
      _scanResults = results;
      _isDetecting = false;
    });
  }

  // Build img and draw rect
  Widget _buildImage() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Image.file(
              _imgFile,
              width: double.infinity,
              //height: 300,
              fit: BoxFit.fill,
            ),
          ),
          _isDetecting
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
    // return SizedBox(
    //   width: 500,
    //   height: 350,
    //   child: Container(
    //     constraints: BoxConstraints.expand(),
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //         image: Image.file(_imgFile).image,
    //         fit: BoxFit.fill,
    //       ),
    //     ),
    //     child: _scanResults == null
    //         ? Center(
    //             child: CircularProgressIndicator(
    //               valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
    //             ),
    //           )
    //         : Container(),
    //   ),
    // );
  }

  // Build result below img
  Widget _buildResults() {
    var text;

    if (_scanResults == null) {
      text = '';
      return Center(
        child: Text(text, style: Theme.of(context).textTheme.subtitle1),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final result = _scanResults[index] as VisionEdgeImageLabel;
          var text = result.text;
          var title;

          switch (text) {
            case 'banh_mi':
              title = 'Banh mi';
              text =
                  'Banh mi, A Vietnamese street food consisting of a crust of toast with crispy skin and soft intestines; inside is the kernel. Depending on regional flavors or personal preferences, people will create different types of fillings (usually filled with silk rolls, meat, fish, vegetarian food or fruit jam ... with some ingredients. other side dishes such as pâté, avocado, vegetables, chili, pickles ...)';
              break;
            case 'banh_trang_tron':
              title = 'Mixed rice paper';
              text =
                  'Mixed rice paper is a light snack originating from Tay Ninh (Vietnam). This dish is one of the popular snacks among students.\nThis dish has the main ingredient of fiber-cut rice paper, usually, the rice paper mixed everywhere is commonly eaten with shrimp salt, lemon lime, dried beef, quail eggs, leafy vegetables, ... mixed with fried dried shrimp, the remaining ingredients vary according to the seller, the common ingredients are burnt beef lungs, laksa leaves, sour papaya, soy sauce, peanuts, ... They are usually packed. and sold in small plastic bags at low prices.';
              break;
            case 'banh_xeo':
              title = 'Pancake';
              text =
                  'Pancake, in Hue, this dish is often accompanied by barbecue, the sauce is broth including soy sauce, liver, peanuts. In the South of Vietnam, the cake has more eggs and people eat pancakes dipped in sweet and sour fish sauce. In the North of Vietnam, in addition to the ingredients as elsewhere, also add thinly sliced beans or sliced taro.';
              break;
            case 'bun_bo':
              title = 'Beef rice noodles';
              text =
                  'Beef rice noodles is one of the specialties of Hue, although this noodle dish is popular in all three regions in Vietnam and also overseas Vietnamese. In Hue, this dish is simply called "bun bo" or more specifically "bun bo bo pork". Other localities called "Hue beef vermicelli", "Hue original beef noodle" to indicate the origin of this dish. The main ingredients of the dish are vermicelli, beef, pork, pork rolls, and a distinctive red broth and lemongrass and sauces. A bowl of vermicelli is sometimes added to undercooked beef, crab rolls, and other ingredients depending on the cook\'s preference.';
              break;
            case 'bun_dau_mam_tom':
              title = 'Rice noodles with tofu and shrimp paste';
              text =
                  'Rice noodles with tofu and shrimp paste is a simple, rustic dish in the cuisine of North Vietnam. This is a dish often used as a snack, to eat. The main ingredients include fresh vermicelli, golden fried tofu, spring rolls, sour spring rolls, shrimp paste mixed with lemon, chili and served with herbs such as perilla, oregano, basil, lettuce, tomato cannon ...Like other folk dishes, the price is cheap, so many people of the popular population eat so the income of those who sell these dishes is quite high.';
              break;
            case 'com_tam':
              title = 'Broken rice';
              text =
                  'Broken rice is a Vietnamese dish made from rice with broken rice grains. Broken rice refers to broken rice grains, and rice is cooked rice. Although there are many different names such as Saigon broken rice, especially the Saigon name, the main ingredients remain the same for almost everywhere.Broken rice dish with grilled ribs, pork skin, pork rolls, eggs are often used as breakfast, but now broken rice is available in some restaurants for lunch, dinner or dinner with many kinds of food.';
              break;
            case 'goi_cuon':
              title = 'Spring roll';
              text =
                  'Spring roll, also known as spring roll (Northern dialect), is a fairly popular dish in Vietnam. Spring rolls originated from the South of Vietnam called spring rolls - made up of ingredients including lettuce, bean sprout, herbs, basil, perilla, dried shrimp, herbs, boiled meat, fresh shrimp ... all rolled in a rice paper wrap. The spices used are chili sauce mixed with roasted peanuts, pounded with oil and dried onions .... all chopped and rolled in the shell made of flour. The spices used are chili sauce mixed with crushed roasted peanuts in oil and dried onions.';
              break;
            case 'pha_lau':
              title = 'Pha lau';
              text =
                  'Pha lau is a Vietnamese dish, made from pork meat and offal that is braised in a spiced stock (with curry powder sometimes added). Small wooden sticks are used to pick up the meat, which is then dipped in pepper, lime and chili fish sauce and served with rice, noodle or banh mi.';
              break;
            case 'pho':
              title = 'Pho';
              text =
                  'Pho is a Vietnamese soup consisting of broth, rice noodles, herbs, and meat (usually beef), sometimes chicken. Pho is a popular food in Vietnam where it is served in households, street stalls and restaurants countrywide. Pho is considered Vietnam\'s national dish.';
              break;
            case 'sup_cua':
              title = 'Crab sup';
              text =
                  'Crab sup is an easy soup with the main ingredient, crab meat, chicken eggs or quail eggs in addition to the chicken bones to make soup pot sweet and nutritious or corn.';
              break;
          }

          // return ListTile(
          //   title: Center(child: Text(text)),
          // );
          return Column(
            children: <Widget>[
              Text(title, style: TextStyle(fontSize: 18)),
              ListTile(
                title: Center(child: Text(text, style: TextStyle(fontSize: 15))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: RaisedButton(
                    child: Text('Translate'),
                    onPressed: () {
                     LanguageTranslation.navigate(context, text: text);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Detect'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Gallery'),
                    onPressed: () => _getAndScanImg(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: RaisedButton(
                    child: Text('Camera'),
                    onPressed: () => _getAndScanImg(ImageSource.camera),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.grey),
                ),              
                child: _imgFile == null
                    ? Center(
                        child: Text('No image selected'),
                      )
                    : Column(
                        children: <Widget>[
                          _buildImage(),
                          //_buildResults(),
                        ],
                      ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: RaisedButton(
              child: Text('Detect'),
              onPressed: () {
                if (_imgFile != null) _scanImg(_imgFile);
              },
            ),
          ),
          Flexible(
            flex: 1,
            child: _buildResults()),
          // _imgFile == null
          //     ? Center(
          //         child: Text('No image selected'),
          //       )
          //     : Column(
          //         children: <Widget>[
          //           _buildImage(),
          //           _buildResults(),
          //         ],
          //       ),
        ],
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: <Widget>[
      //     Padding(
      //       padding: const EdgeInsets.only(left: 34),
      //       child: FloatingActionButton(
      //         heroTag: 'btn1',
      //         child: Icon(Icons.camera_alt),
      //         onPressed: () {
      //           _getAndScanImg(ImageSource.camera);
      //         },
      //       ),
      //     ),
      //     FloatingActionButton(
      //       heroTag: 'btn2',
      //       child: Icon(Icons.image),
      //       onPressed: () {
      //         _getAndScanImg(ImageSource.gallery);
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}
