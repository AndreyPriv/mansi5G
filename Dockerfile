FROM --platform=linux/amd64 python:3.10-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
COPY /model

CMD ["python", "app.py"]
