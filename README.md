# devops-2022-02_project

<div id="header" align="center">
  <img src="https://media.giphy.com/media/5eLDrEaRGHegx2FeF2/giphy.gif" width="180"/>
</div>
<div id="badge" align="center">
  <a href="https://www.linkedin.com/in/%D1%81%D0%B5%D1%80%D0%B3%D0%B5%D0%B9-%D0%B0%D0%BB%D0%B8%D0%BC%D0%BE%D0%B2-a4522568/">
  <img src="https://img.shields.io/badge/LinkedIn-blue?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn Badge"/>
  </a>
  <a href="https://spb.hh.ru/resume/b509aa89ff01dcae2a0039ed1f55716850524a">
  <img src="https://img.shields.io/badge/HH.RU-red?style=for-the-badge" alt="Youtube Badge"/>
  <a>
</div>

## Проект от курса OTUS devops-2022-02
Основа проекта:
* [Crawler] (https://github.com/express42/search_engine_crawler "Crawler")
* [UI] (https://github.com/express42/search_engine_ui "UI)


## Внесеные изменения по проекту:
1. **crawler.py** 
> channel.queue_declare(queue=mqqueue, **durable=True**) \
Для того, что бы очередь была согласована со стороны Crawler

Иначе контейнер не запускался:
```
rabbitmq    | 2022-07-22 09:42:14.389534+00:00 [error] <0.598.0> Channel error on connection <0.589.0> (10.0.2.5:41960 -> 10.0.2.2:5672, vhost: '/', user: 'sm0ke'), channel 1:
rabbitmq    | 2022-07-22 09:42:14.389534+00:00 [error] <0.598.0> operation queue.declare caused a channel exception precondition_failed: inequivalent arg 'durable' for queue 'rabbitmq_queue' in vhost '/': received 'false' but current is 'true'
rabbitmq    | 2022-07-22 09:42:14.404201+00:00 [warning] <0.589.0> closing AMQP connection <0.589.0> (10.0.2.5:41960 -> 10.0.2.2:5672, vhost: '/', user: 'sm0ke'):
rabbitmq    | 2022-07-22 09:42:14.404201+00:00 [warning] <0.589.0> client unexpectedly closed TCP connection
```
2. Создание **password_gen_rabbit.sh**
> Скрипт для генерации пароля для пользователя RabbitMQ согласно документации

Иначе:
```
Login failed
```
3. **search_engine_ui/requirements.txt**
> Добавлен MarkupSafe>=2.0

Иначе приложение либо не запускается с 0.23 версией, или Jinja2 не может вернуть index.html
