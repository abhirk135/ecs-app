FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt ./
COPY src/ ./src/

RUN pip install --no-cache-dir -r requirements.txt

ENV FLASK_APP=src/app.py

EXPOSE 5000

WORKDIR /app/src
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]