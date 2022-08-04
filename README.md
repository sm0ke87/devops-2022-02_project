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
* [Crawler](https://github.com/express42/search_engine_crawler "Crawler")
* [UI](https://github.com/express42/search_engine_ui "UI")

## Техническое задание

    - [ ] Создание и управление инфраструктурой:
        - [x] Ресурсы и возможности YC
        - [x] Инфраструктура CI/CD на основе Gitlab:
            - [x] Gitlab
            - [x] Gtilab-runner
            - [x] Kubernetes сluster 
        - [ ] Сбор полезных метрик для постоянного мониторинга
    
    - [x] Infrastructure as Code - Terraform
    - [x] Управление конфигурациями - Ansible

### Terrafrom + Ansible
Terrafrom разворачивает 2 инстанса: \
    1.При разворачивании первого и второго инстанса отрабатывается Provisioner c Ansible и производит установку Docker-compose c Gitlab(или gitlab-runner) \
    2.Второй инстанс будет исполнять роль раннера, который мы настроем вручную для сборки приложения, так как раннер привязывается к проекту, а не гитлабу в целом, запускается c прописыванием ключа в env и запуском docker-compose

Terrafrom так же разворачивает кластер кубернетиса в YC, все остальные действия происходят через контекст kubectl, а именно: \
    1. Установка из Helm Nginx-ingress \
    2. Установка из Helm ArgoCD

### Pipline's
Giltab-ci состоит из трех этапов:
* Тестирование приложения ui и crawler в среде созданной docker-compose
* Сборка образов crawler, ui, rabbitMQ их тегирования и отправка на хранение в регистри [DockerHub](https://hub.docker.com/u/sm0ke87 "DockerHub by sm0ke87")
* Создание ветки мастер с кастомизацией деплоя через файл кастомизации, для того, что бы не изменять основной деплоймент

### Разворачивание приложения
ArgoCD остлеживает основную ветку main, последний стейдж делает ответвление от основной ветки, вносит изменения в файл kustomization.yaml, конкретно тэгирует докер контейнеры. Если все тесты прошли успешно, то можно смерджить ветку, причем все тесты пропустятся автоматически, а AgroCD подхватит новую конфигурацию main ветки и внесет изменения в соответсвии с деплойментом и файлом кастомизации, тем самым мы соблюдаем подход GitOps.

С подходом GitOps сокращается колчество хранения секретов для проекта. Так как автоматизация достигается не взаимодействием через kubectl, а через main ветку.

### Сбор метрик
- План

## Внесеные изменения по проекту:
1. **crawler.py** 
> channel.queue_declare(queue=mqqueue, **durable=True**) \
Для того, что бы очередь была согласована со стороны Crawler

Иначе контейнер не запускался:
```service-acc
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
