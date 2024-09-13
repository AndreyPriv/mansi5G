# Базовый образ Python
FROM python:3.10-slim

# Устанавливаем необходимые зависимости для системы
RUN apt-get update && apt-get install -y \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем pip
RUN pip install --upgrade pip

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файл зависимостей в контейнер
COPY requirements.txt .

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем скрипт приложения
COPY app.py .

# Копируем папку с моделью
COPY model/ ./model/

# Команда для запуска приложения
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
