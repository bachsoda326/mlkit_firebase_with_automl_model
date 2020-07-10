import 'dart:async';
import 'dart:io';
import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkitfirebasefeatures/bloc/detect_options_bloc.dart';
import 'package:mlkitfirebasefeatures/detector_painter.dart';
import 'package:mlkitfirebasefeatures/screen/language_translation.dart';

class OthersPictureScanner extends StatefulWidget {
  static Future<dynamic> navigate(BuildContext context, {String detector}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => OthersPictureScanner(detector: detector),
    ));
  }

  final String detector;

  OthersPictureScanner({this.detector});

  @override
  State<StatefulWidget> createState() {
    return _OthersPictureScannerState();
  }
}

class _OthersPictureScannerState extends State<OthersPictureScanner> {
  File _imgFile;
  Size _imgSize;
  dynamic _scanResults;
  bool _isDetecting = false;
  String resultText;

  final _detectOptions = <String>['Text', 'Barcode', 'Face', 'Image label'];
  String _currentDetector;

  final TextRecognizer _textRecognizer = FirebaseVision.instance.textRecognizer();
  final BarcodeDetector _barcodeDetector = FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();

  DetectOptionsBloc _optionsBloc = DetectOptionsBloc();

  @override
  void initState() {
    super.initState();
    _currentDetector = widget.detector ?? _detectOptions[0];
  }

  @override
  void dispose() {
    super.dispose();
    _optionsBloc.dispose();
  }

  // Get img from gallery/camera
  Future<void> _getImg(ImageSource source) async {
    _scanResults = null;
    final imgFile = await ImagePicker.pickImage(source: source);

    if (imgFile != null) {
      setState(() {
        _imgFile = imgFile;
      });
    }
  }

  // Get img size for drawing rect
  Future<void> _getImgSize(File imgFile) async {
    Completer<Size> completer = Completer<Size>();

    final Image img = Image.file(imgFile);
    img.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final imgSize = await completer.future;

    setState(() {
      _imgSize = imgSize;
    });
  }

  // Scan img
  Future<void> _scanImg(File imgFile) async {
    setState(() {
      _isDetecting = true;
      _scanResults = null;
    });

    _getImgSize(imgFile);

    final FirebaseVisionImage visionImg = FirebaseVisionImage.fromFile(imgFile);
    dynamic results;

    switch (_currentDetector) {
      case 'Text':
        results = await _textRecognizer.processImage(visionImg);
        break;
      case 'Barcode':
        results = await _barcodeDetector.detectInImage(visionImg);
        break;
      case 'Face':
        results = await _faceDetector.processImage(visionImg);
        break;
      case 'Image label':
        results = await _imageLabeler.processImage(visionImg);
        break;
    }

    setState(() {
      _scanResults = results;
      _isDetecting = false;
    });
  }

  CustomPainter _buildPaints() {
    switch (_currentDetector) {
      case 'Text':
        return TextDetectorPainter(_imgSize, _scanResults);
      case 'Barcode':
        return BarcodeDetectorPainter(_imgSize, _scanResults);
      case 'Face':
        return FaceDetectorPainter(_imgSize, _scanResults);
      case 'Image label':
        return LabelDetectorPainter(_imgSize, _scanResults);
    }
  }

  // Build img and draw rect
  Widget _buildImage() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey),
              image: DecorationImage(
                image: Image.file(_imgFile).image,
                fit: BoxFit.fill,
              ),
            ),
            child: _imgSize == null || _scanResults == null
                ? const SizedBox()
                : _currentDetector == 'Image label' ? const SizedBox() : CustomPaint(painter: _buildPaints()),
          ),
          // ClipRRect(
          //   borderRadius: BorderRadius.all(Radius.circular(5)),
          //   child: Image.file(
          //     _imgFile,
          //     width: double.infinity,
          //     //height: 300,
          //     fit: BoxFit.fill,
          //   ),
          // ),
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
  }

  // Build result below img
  Widget _buildResults() {
    if (_scanResults == null) {
      resultText = '';
      return Center(
        child: Text(resultText, style: Theme.of(context).textTheme.subtitle1),
      );
    } else {
      // Text detect result
      if (_currentDetector == 'Text') {
        final result = _scanResults as VisionText;
        resultText = result.text;
        return Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  //shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(resultText, textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
              //Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: RaisedButton(
                  child: Text('Transalte'),
                  onPressed: () {
                    if (widget.detector != null)
                      Navigator.pop(context, resultText);
                    else
                      LanguageTranslation.navigate(context, text: resultText);
                  },
                ),
              ),
            ],
          ),
        );
      }

      // Other detect result
      return Expanded(
        child: ListView.builder(
          itemCount: _scanResults.length,
          itemBuilder: (context, index) {
            switch (_currentDetector) {
              case 'Barcode':
                final result = _scanResults[index] as Barcode;
                resultText = result.rawValue;
                break;
              // case 'Face':
              //   final result = _scanResults[index] as Face;
              //   text = 'SmilingProbability: ${result.smilingProbability}, TrackingId: ${result.trackingId}';
              //   break;
              case 'Image label':
                final result = _scanResults[index] as ImageLabel;
                resultText = result.text;
                break;
              default:
                break;
            }

            return ListTile(
              title: Text(resultText),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Others Detect'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text('From gallery'),
                onPressed: () => _getImg(ImageSource.gallery),
              ),
              RaisedButton(
                child: Text('From camera'),
                onPressed: () => _getImg(ImageSource.camera),
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
                      ],
                    ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              StreamBuilder<String>(
                  stream: _optionsBloc.detectDropdownStream,
                  initialData: _currentDetector,
                  builder: (context, snapshot) {
                    // List detect options
                    return DropdownButton(
                      value: snapshot.data,
                      onChanged: (val) {
                        _currentDetector = val;
                        _optionsBloc.setOption(val);
                      },
                      items: _detectOptions
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                    );
                  }),
              // Button detect
              RaisedButton(
                child: Text('Detect'),
                onPressed: () {
                  if (_imgFile != null) _scanImg(_imgFile);
                },
              ),
            ],
          ),
          _buildResults(),
        ],
      ),
    );
  }
}
