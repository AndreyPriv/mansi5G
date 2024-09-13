# ������� ����� Python
FROM python:3.10-slim

# ������������� ����������� ����������� ��� �������
RUN apt-get update && apt-get install -y \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# ������������� pip
RUN pip install --upgrade pip

# ������������� ������� ����������
WORKDIR /app

# �������� ���� ������������ � ���������
COPY requirements.txt .

# ������������� Python �����������
RUN pip install --no-cache-dir -r requirements.txt

# �������� ������ ����������
COPY app.py .

# �������� ����� � �������
COPY model/ ./model/

# ������� ��� ������� ����������
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
