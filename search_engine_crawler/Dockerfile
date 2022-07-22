FROM python:3.6.0-alpine

WORKDIR /search_engine_crawler

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbitmq
ENV RMQ_QUEUE rabbitmq_queue
ENV RMQ_USERNAME sm0ke
ENV RMQ_PASSWORD default_password
ENV CHECK_INTERVAL=10
ENV EXCLUDE_URLS='.*github.com'

CMD [ "python3", "-u" , "crawler/crawler.py", "https://vitkhab.github.io/search_engine_test_site/"]
