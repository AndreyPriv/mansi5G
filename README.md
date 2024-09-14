# mansi5G

# Machine Translation API (Russian-Mansi)

Этот проект реализует машинный перевод с русского на мансийский язык с использованием библиотеки `transformers` и модели Seq2Seq. API создано на базе FastAPI и упаковано в Docker-контейнер для удобства развертывания.

## Структура проекта

- `app.py` — Основной файл FastAPI-приложения, содержащий логику для обработки запросов и перевода текста.
- `model/` — Директория, содержащая предобученную PyTorch модель (например, `pytorch_model.bin`).
- `requirements.txt` — Список зависимостей для проекта.
- `Dockerfile` — Файл для сборки Docker-образа с сервисом перевода.
- `README.md` — Этот файл с инструкциями по установке и использованию.
- `main.dart` — основной файл для Flutter-приложений, написанных на языке программирования Dart. Он содержит код, который запускает Flutter-приложение.

### Видео демонстрация работы

[Посмотреть видео на Яндекс.Диске](https://disk.yandex.ru/i/xwFbzw74C2ZrCQ)

### Ссылка на модель
[Модель](https://drive.google.com/drive/folders/1WTjwXgYZ0hSjLzmdpoQ1eWM6TXOTbTar)
[Hugging Face](https://huggingface.co/Anzovi/nllb-rus-mansi-V2/tree/main)
## Установка и запуск

### 1. Локальная установка

1. 
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # Для Linux/macOS
   # .venv\Scripts\activate    # Для Windows
   pip install -r requirements.txt
   uvicorn app:app --reload

Приложение будет доступно по адресу: http://127.0.0.1:8000.


API
POST /translate
Этот эндпоинт принимает текст для перевода с исходного языка на целевой.

Пример запроса:
```bash
curl -X POST "http://127.0.0.1:8000/translate" \
-H "Content-Type: application/json" \
-d '{
    "text": "Пример текста для перевода",
    "src_lang": "rus_Cyrl",
    "tgt_lang": "mns_Cyrl"
}' 
```
```bash
Пример ответа:
{
  "translations": [
    "Мансийский перевод текста"
  ]
}
```



### 2. Фронтенд проекта
Фронтенд проекта написан на языке Dart с использованием Flutter. Особенность этой технологии заключается в том, что однажды написанный код можно запускать в веб-браузере, как локальное приложение для Windows или Mac, и даже на мобильных устройствах с минимальными изменениями.

Проект был разработан для запуска в качестве веб-сервиса, поэтому локальный запуск выполняется командой:
```
flutter run
```

Если необходимо указать браузер или способ отображения, запуск можно произвести командой, например:

```
flutter run -d chrome --web-renderer html
```

Чтобы создать файлы, пригодные для деплоя веб-сайта, используется команда:
```
flutter build web --web-renderer html
```

Она компилирует программу в необходимые для запуска веб-сервиса HTML и JS файлы, которые размещаются в директории build/web.

Zip архив проекта доступен по [ссылке](https://drive.google.com/file/d/1Oj_UkVXXwIYJnhheZoYKyabYsPbnhVIS/view?usp=drive_link) на Google Диске.



