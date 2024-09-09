import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для использования Clipboard

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
    'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', 'Backspace'
  ];

  void _swapLanguages() {
    setState(() {
      isRussianToMansi = !isRussianToMansi;
      _translateText(_textController.text);
    });
  }

  void _translateText(String inputText) {
    setState(() {
      if (isRussianToMansi) {
        _translatedText = inputText.toUpperCase();
      } else {
        _translatedText = inputText.toLowerCase();
      }
    });
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
      height: 240, // Ограничиваем высоту клавиатуры (можно подбирать под размер)
      width: 480, // Ограничиваем ширину до размера поля ввода
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 12, // Количество клавиш в ряду
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
                    minimumSize: Size(40, 40), // Квадратные кнопки
                    maximumSize: Size(40, 40), // Фиксированный размер
                    padding: EdgeInsets.zero, // Минимальные отступы
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: _toggleCase,
            child: Text(_isUpperCase ? 'CAPS' : 'CAPS'),
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
    _translateText(_textController.text); // Обработка текста после каждого ввода с виртуальной клавиатуры
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Русско-мансийский переводчик'),
      ),
      body: SingleChildScrollView( // Добавляем прокрутку
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 120,
                              width: 480,
                              child: TextField(
                                controller: _textController,
                                onChanged: (text) {
                                  _translateText(text);
                                },
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
                  IconButton(
                    icon: Icon(Icons.swap_horiz, size: 36),
                    onPressed: _swapLanguages,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isRussianToMansi ? 'Мансийский язык' : 'Русский язык',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 120,
                              width: 480,
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
                  ? _buildVirtualKeyboard() // Ограниченная клавиатура
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
