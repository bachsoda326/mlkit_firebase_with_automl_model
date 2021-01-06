import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlkitfirebasefeatures/screen/picture_others_scanner.dart';

class LanguageTranslation extends StatefulWidget {
  static Future<dynamic> navigate(BuildContext context, {String text, String language}) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LanguageTranslation(text: text, detectedLanguage: language),
    ));
  }

  final String text;
  final String detectedLanguage;

  const LanguageTranslation({this.text, this.detectedLanguage});

  @override
  State<StatefulWidget> createState() {
    return _LanguageTranslationState();
  }
}

class _LanguageTranslationState extends State<LanguageTranslation> {
  final LanguageIdentifier languageIdentifier = FirebaseLanguage.instance.languageIdentifier();

  final List<String> _languages1 = ['Language detect', 'English', 'Vietnamese', 'Japanese'];
  final List<String> _languages2 = ['English', 'Vietnamese', 'Japanese'];
  String _firstLanguage;
  String _targetLanguage;
  var _supportFirstLanguage;
  var _supportTargetLanguage;
  final _inputTextController = TextEditingController();
  String _inputText;
  String _translatedText = '';

  bool _showErase = false;
  bool _isEraseHide = false;

  @override
  void initState() {
    _firstLanguage = widget.detectedLanguage == null ? _languages1[0] : widget.detectedLanguage;
    _targetLanguage = _languages1[1];
    _changeLanguage(language: _firstLanguage);
    _changeLanguage(language: _targetLanguage, isTargetLanguage: true);
    _inputTextController.text = widget.text;
    super.initState();
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    super.dispose();
  }

  void _translate() async {
    setState(() {
      _translatedText = null;
    });

    _inputText = _inputTextController.text;

    if (_firstLanguage == 'Language detect') {
      final List<LanguageLabel> labels = await languageIdentifier.processText(_inputText);
      _supportFirstLanguage = labels[0].languageCode;
    }
    var result = await FirebaseLanguage.instance.languageTranslator(_supportFirstLanguage, _supportTargetLanguage).processText(_inputText);

    setState(() {
      _translatedText = result;
    });
  }

  void _changeLanguage({String language, bool isTargetLanguage = false}) {
    var supportLanguage;
    switch (language) {
      case 'English':
        supportLanguage = SupportedLanguages.English;
        break;
      case 'Vietnamese':
        supportLanguage = SupportedLanguages.Vietnamese;
        break;
      case 'Japanese':
        supportLanguage = SupportedLanguages.Japanese;
        break;
      default:
        supportLanguage = SupportedLanguages.English;
    }

    if (!isTargetLanguage) {
      _supportFirstLanguage = supportLanguage;
    } else {
      _supportTargetLanguage = supportLanguage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Translate', style: GoogleFonts.ptSerif()),
        backgroundColor: Colors.blue[300],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // First lang
                  DropdownButton(
                    value: _firstLanguage,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.arrow_downward, color: Colors.blueGrey),
                    ),
                    iconSize: 20,
                    elevation: 16,
                    onChanged: (value) {
                      setState(() {
                        _firstLanguage = value;
                      });
                      _changeLanguage(language: _firstLanguage);
                    },
                    items: _languages1.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value, style: GoogleFonts.ptSerif()));
                    }).toList(),
                  ),
                  Center(
                    child: Text('|', style: TextStyle(color: Colors.grey)),
                  ),
                  // Second lang
                  DropdownButton(
                    value: _targetLanguage,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.arrow_downward, color: Colors.blueGrey),
                    ),
                    iconSize: 20,
                    elevation: 16,
                    onChanged: (value) {
                      setState(() {
                        _targetLanguage = value;
                      });
                      _changeLanguage(language: _targetLanguage, isTargetLanguage: true);
                    },
                    items: _languages2.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value, style: GoogleFonts.ptSerif()));
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  //height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          // Input
                          child: TextField(
                            controller: _inputTextController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter text',
                              hintStyle: GoogleFonts.ptSerif(),
                            ),
                            style: TextStyle(fontSize: 15),
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            onTap: () {
                              if (!_showErase)
                                setState(() {
                                  _showErase = true;
                                  _isEraseHide = false;
                                });
                            },
                            // onChanged: (val) {
                            //   if (!_isEraseShow)
                            //     setState(() {
                            //       _isEraseShow = true;
                            //     });
                            // },
                            onSubmitted: (val) {
                              if (val.isEmpty) {
                                setState(() {
                                  _showErase = false;
                                });
                              } else {
                                setState(() {
                                  _isEraseHide = true;
                                });
                              }
                            },
                          ),
                        ),
                        _showErase
                            ? IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    if (_inputTextController.text.isNotEmpty) {
                                      _inputTextController.clear();
                                    }
                                    // else {
                                    //   _inputTextController.clear();
                                    // }
                                    if (_isEraseHide) _showErase = false;
                                  });
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Button transalte
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      icon: Icon(Icons.art_track, color: Colors.blue),
                      label: Text('Detect text', style: GoogleFonts.ptSerif()),
                      onPressed: () async {
                        var textResult = await OthersPictureScanner.navigate(context, detector: 'Text');
                        if (textResult != null) {
                          setState(() {
                            _inputTextController.text = textResult;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  // Button detect text
                  Expanded(
                    child: RaisedButton.icon(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      icon: Icon(Icons.translate, color: Colors.blue),
                      label: Text('Translate', style: GoogleFonts.ptSerif()),
                      onPressed: _translate,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: double.infinity,
                  //height: 160,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  // Translate
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _translatedText != null
                        ? SingleChildScrollView(
                            child: Text(
                              _translatedText,
                              style: GoogleFonts.ptSerif(fontSize: 15),
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
