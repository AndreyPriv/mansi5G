import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Русско-мансийский переводчик',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Noto Sans', // Using Noto Sans for better Cyrillic support
      ),
      home: TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  bool isRussianToMansi = true;
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isKeyboardVisible = false;
  bool _isUpperCase = true;

  final List<String> _keyboardKeys = [
    'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ',
    'ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э',
    'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю',
    'а̄', 'е̄', 'ё̄', 'ӣ', 'ӈ', 'о̄', 'ӯ', 'ы̄', 'э̄', 'ю̄', 'я̄', // Adding Mansi-specific characters
    'Backspace'
  ];

  void _swapLanguages() {
    setState(() {
      isRussianToMansi = !isRussianToMansi;
    });
  }

  Future<void> _translateText() async {
    final String apiUrl = 'http://localhost:8000/translate'; // Update this URL if your backend is on a different machine or port
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': _textController.text,
          'src_lang': isRussianToMansi ? 'rus_Cyrl' : 'mns_Cyrl',
          'tgt_lang': isRussianToMansi ? 'mns_Cyrl' : 'rus_Cyrl',
        }),
      );

      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _translatedText = data['translations'][0];
        });
        print('Decoded translation: $_translatedText');
      } else {
        setState(() {
          _translatedText = 'Error: Unable to translate (Status ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Error: Unable to connect to the server ($e)';
      });
    }
  }

  void _copyToClipboard() {
    if (_translatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Текст скопирован в буфер обмена')),
      );
    }
  }

  void _toggleKeyboard() {
    setState(() {
      _isKeyboardVisible = !_isKeyboardVisible;
    });
  }

  void _toggleCase() {
    setState(() {
      _isUpperCase = !_isUpperCase;
    });
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      height: 280, // Increased height to accommodate additional keys
      width: 480,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _keyboardKeys.length,
              itemBuilder: (context, index) {
                String key = _isUpperCase
                    ? _keyboardKeys[index].toUpperCase()
                    : _keyboardKeys[index].toLowerCase();
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () => _onKeyPress(key),
                    child: Text(key),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _toggleCase,
            child: Text(_isUpperCase ? 'CAPS' : 'caps'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(40, 40),
              maximumSize: Size(40, 40),
            ),
          ),
        ],
      ),
    );
  }

  void _onKeyPress(String key) {
    if (key == 'Backspace') {
      if (_textController.text.isNotEmpty) {
        setState(() {
          _textController.text =
              _textController.text.substring(0, _textController.text.length - 1);
        });
      }
    } else {
      setState(() {
        _textController.text += key;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Русско-мансийский переводчик'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isRussianToMansi ? 'Русский язык' : 'Мансийский язык',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 200,
                              width: 680,
                              child: TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Введите текст',
                                ),
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.keyboard),
                              onPressed: _toggleKeyboard,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.swap_horiz, size: 36),
                        onPressed: _swapLanguages,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _translateText,
                        child: Text('Перевести'),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isRussianToMansi ? 'Мансийский язык' : 'Русский язык',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 200,
                              width: 680,
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                _translatedText.isEmpty
                                    ? 'Перевод будет здесь'
                                    : _translatedText,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.copy),
                              onPressed: _copyToClipboard,
                              tooltip: 'Копировать текст',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isKeyboardVisible
                  ? _buildVirtualKeyboard()
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}