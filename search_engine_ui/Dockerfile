FROM python:3.6.5-alpine

WORKDIR /search_engine_ui

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py

COPY requirements-test.txt requirements-test.txt
COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt && \
    pip install -r requirements-test.txt

COPY . .

WORKDIR /search_engine_ui/ui


CMD ["gunicorn", "ui:app", "-b", "0.0.0.0" ]
