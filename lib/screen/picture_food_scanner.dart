import 'dart:async';
import 'dart:io';
import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

          return ListTile(
            title: Center(child: Text(text)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('From gallery'),
                onPressed: () => _getAndScanImg(ImageSource.gallery),
              ),
              RaisedButton(
                child: Text('From camera'),
                onPressed: () => _getAndScanImg(ImageSource.camera),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.grey),
              ),
              height: 300,
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
          RaisedButton(
            child: Text('Detect'),
            onPressed: () {
              if (_imgFile != null) _scanImg(_imgFile);
            },
          ),
          _buildResults(),
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
