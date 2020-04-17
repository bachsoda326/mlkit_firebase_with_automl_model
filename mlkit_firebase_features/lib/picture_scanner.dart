import 'dart:async';
import 'dart:io';

import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkitfirebasefeatures/detector_painter.dart';

class PictureScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PictureScannerState();
  }
}

class _PictureScannerState extends State<PictureScanner> {
  File _imgFile;
  Size _imgSize;
  dynamic _scanResults;
  Detector _currentDetector = Detector.text;

  final TextRecognizer _textRecognizer =
      FirebaseVision.instance.textRecognizer();
  final BarcodeDetector _barcodeDetector =
      FirebaseVision.instance.barcodeDetector();
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler _imageLabeler = FirebaseVision.instance.imageLabeler();
  final VisionEdgeImageLabeler _visionEdgeImageLabeler = FirebaseVision.instance
      .visionEdgeImageLabeler('model', ModelLocation.Local);

  // Get img from gallery/camera and scan
  Future<void> _getAndScanImg(String source) async {
    var imgSource;

    if (source == 'Gallery') {
      imgSource = ImageSource.gallery;
    } else {
      imgSource = ImageSource.camera;
    }

    final imgFile = await ImagePicker.pickImage(source: imgSource);

    if (imgFile != null) {
      _getImgSize(imgFile);
      _scanImg(imgFile);
    }

    setState(() {
      _imgFile = imgFile;
    });
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
      _scanResults = null;
    });

    final FirebaseVisionImage visionImg = FirebaseVisionImage.fromFile(imgFile);
    dynamic results;

    switch (_currentDetector) {
      case Detector.text:
        results = await _textRecognizer.processImage(visionImg);
        break;
      case Detector.barcode:
        results = await _barcodeDetector.detectInImage(visionImg);
        break;
      case Detector.face:
        results = await _faceDetector.processImage(visionImg);
        break;
      case Detector.label:
        results = await _imageLabeler.processImage(visionImg);
        break;
      case Detector.visionEdgeLabel:
        results = await _visionEdgeImageLabeler.processImage(visionImg);
        break;
    }

    setState(() {
      _scanResults = results;
    });
  }

  // Build img and draw rect
  Widget _buildImage() {
    return SizedBox(
      width: 500,
      height: 250,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.file(_imgFile).image,
            fit: BoxFit.fill,
          ),
        ),
        child: _imgSize == null || _scanResults == null
            ? Center(
                child: Text(
                  "Scanning",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 30.0,
                  ),
                ),
              )
            : _currentDetector == Detector.label ||
                    _currentDetector == Detector.visionEdgeLabel
                ? Container()
                : CustomPaint(painter: _buildPaints()),
      ),
    );
  }

  CustomPainter _buildPaints() {
    switch (_currentDetector) {
      case Detector.text:
        return TextDetectorPainter(_imgSize, _scanResults);
      case Detector.barcode:
        return BarcodeDetectorPainter(_imgSize, _scanResults);
      case Detector.face:
        return FaceDetectorPainter(_imgSize, _scanResults);
      case Detector.label:
        return LabelDetectorPainter(_imgSize, _scanResults);
      case Detector.visionEdgeLabel:
        return VisionEdgeLabelDetectorPainter(_imgSize, _scanResults);
    }
  }

  // Build result below img
  Widget _buildResults() {
    var text;

    if (_scanResults == null) {
      text = 'Nothing detected';
      return Expanded(
        child: Center(
          child: Text(text, style: Theme.of(context).textTheme.subhead),
        ),
      );
    }

    if (_currentDetector == Detector.text) {
      final result = _scanResults as VisionText;
      text = result.text;
      return Expanded(
        child: Text(text),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          var text;

          switch (_currentDetector) {
            case Detector.text:
//              final result = _scanResults[index] as VisionText;
//              text = result.text;
              break;
            case Detector.barcode:
              final result = _scanResults[index] as Barcode;
              text = result.rawValue;
              break;
            case Detector.face:
              final result = _scanResults[index] as Face;
              text =
                  'SmilingProbability: ${result.smilingProbability}, TrackingId: ${result.trackingId}';
              break;
            case Detector.label:
              final result = _scanResults[index] as ImageLabel;
              text = result.text;
              break;
            case Detector.visionEdgeLabel:
              final result = _scanResults[index] as VisionEdgeImageLabel;
              text = result.text;
              break;
          }

          return ListTile(
            title: Text(text),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Picture Scanner'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (value) {
              _currentDetector = value;
              if (_imgFile != null) _scanImg(_imgFile);
            },
            itemBuilder: (context) => <PopupMenuEntry<Detector>>[
              PopupMenuItem(
                child: Text('Detect Text'),
                value: Detector.text,
              ),
              PopupMenuItem(
                child: Text('Detect Barcode'),
                value: Detector.barcode,
              ),
              PopupMenuItem(
                child: Text('Detect Face'),
                value: Detector.face,
              ),
              PopupMenuItem(
                child: Text('Detect Label'),
                value: Detector.label,
              ),
              PopupMenuItem(
                child: Text('Detect Vision Edge Label'),
                value: Detector.visionEdgeLabel,
              ),
            ],
          ),
        ],
      ),
      body: _imgFile == null
          ? Center(
              child: Text('No image selected'),
            )
          : Column(
              children: <Widget>[
                _buildImage(),
                _buildResults(),
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'btn1',
            child: Icon(Icons.image),
            onPressed: () {
              _getAndScanImg('Gallery');
            },
          ),
          FloatingActionButton(
            heroTag: 'btn2',
            child: Icon(Icons.camera_alt),
            onPressed: () {
              _getAndScanImg('Camera');
            },
          ),
        ],
      ),
    );
  }
}
