rabbitmq-server:
  pkg:
    - installed
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq-server
