# Backend 

Этот проект представляет собой бэкенд-сервис на FastAPI, который обрабатывает запросы для машинного перевода с использованием Seq2Seq модели. Запуск и выполнение кода осуществляется через `app.py`.

## Структура проекта

- `app.py` — Основной файл приложения FastAPI, в котором реализован обработчик запросов и логика перевода.
- `model/` — Директория, содержащая предобученную модель для перевода.
- `requirements.txt` — Файл с зависимостями проекта.

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
