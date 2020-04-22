import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageTranslation extends StatefulWidget {
  final String text;
  final String detectedLanguage;

  const LanguageTranslation({this.text, this.detectedLanguage});

  @override
  State<StatefulWidget> createState() {
    return _LanguageTranslationState();
  }
}

class _LanguageTranslationState extends State<LanguageTranslation> {
  final List<String> _languages = ['English', 'Vietnamese', 'Japanese'];
  String _firstLanguage;
  String _targetLanguage;
  var _supportFirstLanguage;
  var _supportTargetLanguage;
  final _inputTextController = TextEditingController();
  var _inputText;
  var _translatedText;

  @override
  void initState() {
    _firstLanguage = widget.detectedLanguage;
    _targetLanguage = _languages[0];
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
    _inputText = _inputTextController.text;
    var result = await FirebaseLanguage.instance
        .languageTranslator(_supportFirstLanguage, _supportTargetLanguage)
        .processText(_inputText);

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
      appBar: AppBar(
        title: Text('Translate'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton(
                value: _firstLanguage,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _firstLanguage = value;
                  });
                  _changeLanguage(
                      language: _firstLanguage);
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
              ),
              Center(
                child: Text('|'),
              ),
              DropdownButton(
                value: _targetLanguage,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                onChanged: (value) {
                  setState(() {
                    _targetLanguage = value;
                  });
                  _changeLanguage(
                      language: _targetLanguage, isTargetLanguage: true);
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
              ),
            ],
          ),
          SizedBox(
            width: 300,
            height: 100,
            child: TextField(
              controller: _inputTextController,
              expands: true,
              maxLines: null,
              minLines: null,
            ),
          ),
          RaisedButton(
            child: Text('Translate'),
            onPressed: _translate,
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                _translatedText ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
