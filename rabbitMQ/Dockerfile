FROM rabbitmq:3-management

ENV RABBITMQ_USER sm0ke
ENV RABBITMQ_PASS default_password
ENV RABBITMQ_NODENAME rabbit@staticrabbit

COPY ./rabbitmq-enabled-plugins /etc/rabbitmq/enabled_plugins
COPY ./rabbitmq.config /etc/rabbitmq/rabbitmq.config
COPY ./rabbitmq-defs.json /etc/rabbitmq/rabbitmq-defs.json
