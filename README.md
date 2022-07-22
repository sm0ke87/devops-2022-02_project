# Проект от курса OTUS devops-2022-02



## Внесеные изменения по проекту:
1. 
**crawler.py** 
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