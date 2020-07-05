import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

class DetectOptionsBloc {
  BehaviorSubject<String> detectDropdownStream = BehaviorSubject();

  String currentOption = 'Barcode';

  void dispose() {
    detectDropdownStream.close();
  }

  void setOption(String val) {
    currentOption = val;
    detectDropdownStream.add(currentOption);
  }
}