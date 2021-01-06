import 'dart:async';
import 'dart:io';
import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        child: Text(resultText, style: GoogleFonts.ptSerif()),
      );
    } else {
      bool _isResultNull = false;
      switch (_currentDetector) {
        case 'Text':
          if (_scanResults.text == "") _isResultNull = true;
          break;
        case 'Barcode':
        case 'Face':
        case 'Image label':
          if (_scanResults.length == 0) _isResultNull = true;
          break;
      }

      if (_isResultNull) {
        resultText = 'No result.';
        return Center(
          child: Text(resultText, style: GoogleFonts.ptSerif()),
        );
      }
      // Text detect result
      if (_currentDetector == 'Text') {
        final result = _scanResults as VisionText;
        resultText = result.text;
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                //shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(resultText, textAlign: TextAlign.left, style: GoogleFonts.ptSerif()),
                  ),
                ],
              ),
            ),
            //Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: RaisedButton.icon(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                  icon: Icon(Icons.translate, color: Colors.blue),
                  label: Text('Translate', style: GoogleFonts.ptSerif()),
                  onPressed: () {
                    if (widget.detector != null)
                      Navigator.pop(context, resultText);
                    else
                      LanguageTranslation.navigate(context, text: resultText);
                  },
                ),
              ),
            ),
          ],
        );
      }

      // Other detect result
      return ListView.builder(
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
            title: Text(resultText, style: GoogleFonts.ptSerif()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Others Detect', style: GoogleFonts.ptSerif()),
        backgroundColor: Colors.blue[300],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      icon: Icon(Icons.image, color: Colors.blue),
                      label: Text('Gallery', style: GoogleFonts.ptSerif()),
                      onPressed: () => _getImg(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      icon: Icon(Icons.camera_alt, color: Colors.blue),
                      label: Text('Camera', style: GoogleFonts.ptSerif()),
                      onPressed: () => _getImg(ImageSource.camera),
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
                          child: Text('Choose image.', style: GoogleFonts.ptSerif()),
                        )
                      : Column(
                          children: <Widget>[
                            _buildImage(),
                          ],
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  StreamBuilder<String>(
                      stream: _optionsBloc.detectDropdownStream,
                      initialData: _currentDetector,
                      builder: (context, snapshot) {
                        // List detect options
                        return Expanded(
                          child: DropdownButton(
                            isExpanded: true,
                            value: snapshot.data,
                            onChanged: (val) {
                              _currentDetector = val;
                              _optionsBloc.setOption(val);
                            },
                            items: _detectOptions
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Center(child: Text(e, style: GoogleFonts.ptSerif())),
                                    ))
                                .toList(),
                          ),
                        );
                      }),
                  const SizedBox(width: 5),
                  // Button detect
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      icon: Icon(Icons.art_track, color: Colors.blue),
                      label: Text('Detect', style: GoogleFonts.ptSerif()),
                      onPressed: () {
                        if (_imgFile != null) _scanImg(_imgFile);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(flex: 1, child: _buildResults()),
          ],
        ),
      ),
    );
  }
}
