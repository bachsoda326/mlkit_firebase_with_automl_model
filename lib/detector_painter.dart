import 'dart:ui' as ui;

import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';

enum Detector { text, barcode, face, label, visionEdgeLabel }

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.visionText);

  final Size absoluteImageSize;
  final VisionText visionText;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(var result) {
      return Rect.fromLTRB(
        result.boundingBox.left * scaleX,
        result.boundingBox.top * scaleY,
        result.boundingBox.right * scaleX,
        result.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var block in visionText.blocks) {
      for (var line in block.lines) {
        for (var element in line.elements) {
          paint.color = Colors.green;
          canvas.drawRect(scaleRect(element), paint);
        }
        paint.color = Colors.yellow;
        canvas.drawRect(scaleRect(line), paint);
      }
      paint.color = Colors.red;
      canvas.drawRect(scaleRect(block), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return absoluteImageSize != oldDelegate.absoluteImageSize || visionText != oldDelegate.visionText;
  }
}

class BarcodeDetectorPainter extends CustomPainter {
  BarcodeDetectorPainter(this.absoluteImageSize, this.barcodes);

  final Size absoluteImageSize;
  final List<Barcode> barcodes;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(var result) {
      return Rect.fromLTRB(
        result.boundingBox.left * scaleX,
        result.boundingBox.top * scaleY,
        result.boundingBox.right * scaleX,
        result.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var barcode in barcodes) {
      canvas.drawRect(scaleRect(barcode), paint);
    }
  }

  @override
  bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
    return absoluteImageSize != oldDelegate.absoluteImageSize || barcodes != oldDelegate.barcodes;
  }
}

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces);

  final Size absoluteImageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(var result) {
      return Rect.fromLTRB(
        result.boundingBox.left * scaleX,
        result.boundingBox.top * scaleY,
        result.boundingBox.right * scaleX,
        result.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var face in faces) {
      canvas.drawRect(scaleRect(face), paint);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return absoluteImageSize != oldDelegate.absoluteImageSize || faces != oldDelegate.faces;
  }
}

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.absoluteImageSize, this.labels);

  final Size absoluteImageSize;
  final List<ImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 23.0,
          textDirection: TextDirection.ltr),
    );

    builder.pushStyle(ui.TextStyle(color: Colors.green));
    for (ImageLabel label in labels) {
      builder.addText('Label: ${label.text}, '
          'Confidence: ${label.confidence.toStringAsFixed(2)}\n');
    }
    builder.pop();

    canvas.drawParagraph(
      builder.build()
        ..layout(ui.ParagraphConstraints(
          width: size.width,
        )),
      const Offset(0.0, 0.0),
    );
  }

  @override
  bool shouldRepaint(LabelDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.labels != labels;
  }
}

class VisionEdgeLabelDetectorPainter extends CustomPainter {
  VisionEdgeLabelDetectorPainter(this.imageSize, this.labels);

  final Size imageSize;
  final List<VisionEdgeImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 23.0,
          textDirection: TextDirection.ltr),
    );

    builder.pushStyle(ui.TextStyle(color: Colors.green));
    for (VisionEdgeImageLabel label in labels) {
      builder.addText('Label: ${label.text}, '
          'Confidence: ${label.confidence.toStringAsFixed(2)}');
    }
    builder.pop();

    canvas.drawParagraph(
      builder.build()
        ..layout(ui.ParagraphConstraints(
          width: size.width,
        )),
      const Offset(0.0, 0.0),
    );
  }

  @override
  bool shouldRepaint(VisionEdgeLabelDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.labels != labels;
  }
}