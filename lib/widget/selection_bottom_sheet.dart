import 'package:flutter/material.dart';
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
        color: Colors.white,
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
                Text('Select detection method'),
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
                  child: RaisedButton(
                    child: Text('Picture'),
                    onPressed: () => !widget.others ? FoodPictureScanner.navigate(context) : OthersPictureScanner.navigate(context),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: RaisedButton(
                    child: Text('Camera live'),
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
