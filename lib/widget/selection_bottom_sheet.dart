import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlkitfirebasefeatures/screen/camera_preview_scanner.dart';
import 'package:mlkitfirebasefeatures/screen/picture_food_scanner.dart';
import 'package:mlkitfirebasefeatures/screen/picture_others_scanner.dart';

void showDetectSelectionBottomSheet(BuildContext context, {bool others = false}) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return DetectSelectionSheet(others: others);
      });
}

class DetectSelectionSheet extends StatefulWidget {
  final bool others;

  DetectSelectionSheet({this.others});

  @override
  State<StatefulWidget> createState() {
    return _DetectSelectionSheet();
  }
}

class _DetectSelectionSheet extends State<DetectSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff64b5f6),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Select detection method', style: GoogleFonts.ptSerif(color: Colors.white)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton.icon(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    icon: Icon(Icons.image, color: Colors.blue),
                    label: Text('Picture', style: GoogleFonts.ptSerif()),
                    onPressed: () => !widget.others ? FoodPictureScanner.navigate(context) : OthersPictureScanner.navigate(context),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: RaisedButton.icon(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                    icon: Icon(Icons.camera_alt, color: Colors.blue),
                    label: Text('Camera live', style: GoogleFonts.ptSerif()),
                    onPressed: () => CameraPreviewScanner.navigate(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
