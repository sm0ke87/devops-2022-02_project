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

<div id="Tech_bages" align="center">

![GitLab CI](https://img.shields.io/badge/gitlab%20ci-%23181717.svg?style=for-the-badge&logo=gitlab&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white) ![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white) ![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white) ![RabbitMQ](https://img.shields.io/badge/Rabbitmq-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white) ![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
<br>
![YandexCloud](./icon_white_circ.svg)

</div>

## Проект от курса OTUS devops-2022-02
Основа проекта:
* [Crawler](https://github.com/express42/search_engine_crawler "Crawler")
* [UI](https://github.com/express42/search_engine_ui "UI")

## Техническое задание

- [x] Создание и управление инфраструктурой:
    - [x] Ресурсы и возможности YC
    - [x] Инфраструктура CI/CD на основе Gitlab:
        - [x] Gitlab
        - [x] Gtilab-runner
        - [x] Kubernetes сluster 
    - [x] Сбор полезных метрик для постоянного мониторинга

- [x] Infrastructure as Code - Terraform
- [x] Управление конфигурациями - Ansible
- [ ] Мониторинг по желанию

### Terrafrom + Ansible
Terrafrom разворачивает 2 инстанса: 
  * Giltab и средствами Ansible через роль giltab-ansible и производит установку и запуск Docker-compose c Gitlab. 
  * Gitlab-runner и средствами Ansible через роль 
    gitlab-ansible-runner проивзодит установку Docker-compose с необходимыми в будущем yml и env файлами.

Terrafrom так же разворачивает кластер кубернетиса в YC, все остальные действия происходят через контекст kubectl, а именно: \
    1. Установка из Helm Nginx-ingress \
    2. Установка из Helm ArgoCD

### Pipline's
Giltab-ci состоит из трех этапов:
* Тестирование приложения ui и crawler в среде созданной docker-compose
* Сборка образов crawler, ui, rabbitMQ их тегирования и отправка на хранение в регистри [DockerHub](https://hub.docker.com/u/sm0ke87 "DockerHub by sm0ke87")
* Создание ветки мастер с кастомизацией деплоя через файл кастомизации, для того, что бы не изменять основной деплоймент

### Разворачивание приложения
ArgoCD остлеживает основную ветку main, последний стейдж делает ответвление от основной ветки, вносит изменения в файл kustomization.yaml, конкретно тэгирует докер контейнеры. Если все тесты прошли успешно, то можно смерджить ветку, причем все тесты пропустятся автоматически, а ArgoCD подхватит новую конфигурацию main ветки и внесет изменения в соответсвии с деплойментом и файлом кастомизации, тем самым мы соблюдаем подход GitOps.

С подходом GitOps сокращается колчество хранения секретов для проекта. Так как автоматизация достигается не взаимодействием через kubectl, а через main ветку.

### Сбор метрик
Для сбора метрик, которые отдает приложение и crawler, в Kubernetes разворачивается два сервиса:

* Prometheus c адресом http://ingress-ip/prometheus/graph
* Grafana с адресом http://ingress-ip/grafana
* Ноды контролируются ArgoCD

|:warning: Политики безопасности для YC кластера я не победил, хотя в terraform они прописаны, в части подключение по SSH, поэтому автоматизацию через Ansible не смог произвести, следовательно решение следующее: prometheus и grafana собираются из docker образов и деплоятся в проект, считаю меру более чем применимой|
| :--- |

### Безопасность
Деплойментом прописано использование SSL Let's Encypt для личного домена https://informationsecurity.space


## Как запустить проект
1) Клонируем проект:
```
git clone https://github.com/sm0ke87/devops-2022-02_project.git
``` 
2) Создаем сервсный аккаунт в консоли YC и сохраняем ключ на директорию выше проекта:
```
yc iam key create --service-account-name admin --output ../key.json
```
3) Переходим в каталог terrafrom и запускаем его:
```
terrafrom apply
```
4) После того, как terraform отработает в выходной информации будут следующие адреса:
```
 external_ip_address_gitlab = "51.250.64.177"
 external_ip_address_runner = "51.250.67.137"
```

3) Переходим по адресу gitlab (default login/pass:root/roottoor123), отключаем регистрацию, меняем пароль на какой захотим и импортируем проект с гитхаба:

4) Берем ключ из проекта и регистрируем раннер. В папке раннеа /srv/runner прописываем в env данные поднятого gitlab и поднимаем раннер через docker-compose:
```
ssh login@external_ip_address_runner
cd /srv/runner/
vi .env
docker-compose up -d
```


5) Добавляем вариейбелсы в проект:
```
    CI_REGISTRY docker.io
    CI_REGISTRY_PASSWORD docker_hub_passwod
    CI_REGISTRY_USER docker_hub_login
    CI_TOKEN - токен для root
    CI_USERNAME root
```
5) Подключаем конекст нашего кубер кластера:
```
yc managed-kubernetes cluster get-credentials ID_k8s_cluster  --external
```
6) Создаем ns для ArgoCD: 
```
kubectl create namespace argocd
```
7) Добавляем репозиторий ArgoCD и установим его: 
```
helm repo add argo https://argoproj.github.io/argo-helm

helm install argocd \
	-n argocd \
	--set global.image.repository="argoproj/argocd" \
	--set global.image.tag="v2.4.8" \
	--set server.service.type="LoadBalancer" \
	argo/argo-cd
```

проверяем и узнаем IP(можно посмотреть в консоли YC):

```
kubectl get pods -n argocd
kubbectl get svc -n argocd
```

Забираем пароль для админа ArgoCD:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

9) Добавляем репозитарий Nginx и устанавливаем Ingress-контроллер:
```
helm repo add nginx-stable https://helm.nginx.com/stable

helm install nginx  ingress-nginx/ingress-nginx
```

10) Меняем в .gitlab-ci.yml ip-адреса на новый гитлаб.

11) Переходим в ArgoCD и подключаем репозитарий:
<картинка.жыпег>

12) Создаем приложение и синхронизируем: \
<картинка.жыпег>

13) Переходим по внешним адресам:
* [UI](https://informationsecurity.space/grafana)
* [Prometheus](https://informationsecurity.space/prometheus/graph)
* [Grafana](https://informationsecurity.space/grafana)

|:warning: Grafana нуждается в доп настройке, в части подключения source prometheus|
| :--- |

## Внесеные изменения по проекту:
1. **crawler.py** 
> channel.queue_declare(queue=mqqueue, **durable=True**) \
Для того, что бы очередь была согласована со стороны Crawler

| :bangbang: Или получим Login failed |
| :--- |

```service-acc
rabbitmq    | 2022-07-22 09:42:14.389534+00:00 [error] <0.598.0> Channel error on connection <0.589.0> (10.0.2.5:41960 -> 10.0.2.2:5672, vhost: '/', user: 'sm0ke'), channel 1:
rabbitmq    | 2022-07-22 09:42:14.389534+00:00 [error] <0.598.0> operation queue.declare caused a channel exception precondition_failed: inequivalent arg 'durable' for queue 'rabbitmq_queue' in vhost '/': received 'false' but current is 'true'
rabbitmq    | 2022-07-22 09:42:14.404201+00:00 [warning] <0.589.0> closing AMQP connection <0.589.0> (10.0.2.5:41960 -> 10.0.2.2:5672, vhost: '/', user: 'sm0ke'):
rabbitmq    | 2022-07-22 09:42:14.404201+00:00 [warning] <0.589.0> client unexpectedly closed TCP connection
```
2. Создание **password_gen_rabbit.sh**
> Скрипт для генерации пароля для пользователя RabbitMQ согласно документации

| :bangbang: Или получим Login failed |
| :--- |

3. **search_engine_ui/requirements.txt**
> Добавлен MarkupSafe>=2.0

|:bangbang: Или приложение не запускается с 0.23 версией, или Jinja2 не может вернуть index.html |
| :--- |

