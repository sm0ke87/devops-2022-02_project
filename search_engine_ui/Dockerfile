FROM python:3.6.0-alpine

WORKDIR /search_engine_ui

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

WORKDIR /search_engine_ui/ui


CMD ["gunicorn", "ui:app", "-b", "0.0.0.0" ]
