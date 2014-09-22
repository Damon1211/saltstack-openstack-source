glance-install:
  file.managed:
    - name: /usr/local/src/glance-2014.1.1.tar.gz
    - source: salt://openstack/glance/files/glance-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf glance-2014.1.1.tar.gz && cd glance-2014.1.1 && pip-python install -r requirements.txt && python setup.py install && pip-python install pycrypto-on-pypi
    - unless: pip-python freeze | grep glance==2014.1.1
    - require:
      - pkg: openstack-pkg-init
      - file: glance-install

/var/log/glance:
  file.directory:
    - user: root
    - group: root

/var/run/glance:
  file.directory:
    - user: root
    - group: root

/var/lib/glance:
  file.directory:
    - user: root
    - group: root

/etc/glance:
  file.directory:
    - user: root
    - group: root

/etc/glance/schema-image.json:
  file.managed:
    - source: salt://openstack/glance/files/schema-image.json
    - mode: 644
    - user: root
    - group: root

/etc/glance/policy.json:
  file.managed:
    - source: salt://openstack/glance/files/policy.json
    - mode: 644
    - user: root
    - group: root

/etc/glance/logging.cnf:
  file.managed:
    - source: salt://openstack/glance/files/logging.cnf
    - mode: 644
    - user: root
    - group: root

/etc/glance/glance-registry-paste.ini:
  file.managed:
    - source: salt://openstack/glance/files/glance-registry-paste.ini
    - mode: 644
    - user: root
    - group: root

/etc/glance/glance-api-paste.ini:
  file.managed:
    - source: salt://openstack/glance/files/glance-api-paste.ini
    - mode: 644
    - user: root
    - group: root

/etc/glance/glance-api.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-api.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      MYSQL_SERVER: {{ pillar['glance']['MYSQL_SERVER'] }}
      GLANCE_USER: {{ pillar['glance']['GLANCE_USER'] }}
      GLANCE_PASS: {{ pillar['glance']['GLANCE_PASS'] }}
      GLANCE_DBNAME: {{ pillar['glance']['GLANCE_DBNAME'] }}
      RABBITMQ_HOST: {{ pillar['glance']['RABBITMQ_HOST'] }}
      RABBITMQ_PORT: {{ pillar['glance']['RABBITMQ_PORT'] }}
      RABBITMQ_USER: {{ pillar['glance']['RABBITMQ_USER'] }}
      RABBITMQ_PASS: {{ pillar['glance']['RABBITMQ_PASS'] }}
      AUTH_KEYSTONE_HOST: {{ pillar['glance']['AUTH_KEYSTONE_HOST'] }}
      AUTH_KEYSTONE_PORT: {{ pillar['glance']['AUTH_KEYSTONE_PORT'] }}
      AUTH_KEYSTONE_PROTOCOL: {{ pillar['glance']['AUTH_KEYSTONE_PROTOCOL'] }}
      AUTH_ADMIN_PASS: {{ pillar['glance']['AUTH_ADMIN_PASS'] }}

/etc/glance/glance-registry.conf:
  file.managed:
    - source: salt://openstack/glance/files/glance-registry.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      MYSQL_SERVER: {{ pillar['glance']['MYSQL_SERVER'] }}
      GLANCE_USER: {{ pillar['glance']['GLANCE_USER'] }}
      GLANCE_PASS: {{ pillar['glance']['GLANCE_PASS'] }}
      GLANCE_DBNAME: {{ pillar['glance']['GLANCE_DBNAME'] }}
      AUTH_KEYSTONE_HOST: {{ pillar['glance']['AUTH_KEYSTONE_HOST'] }}
      AUTH_KEYSTONE_PORT: {{ pillar['glance']['AUTH_KEYSTONE_PORT'] }}
      AUTH_KEYSTONE_PROTOCOL: {{ pillar['glance']['AUTH_KEYSTONE_PROTOCOL'] }}
      AUTH_ADMIN_PASS: {{ pillar['glance']['AUTH_ADMIN_PASS'] }}

/etc/init.d/openstack-glance-api:
  file.managed:
    - source: salt://openstack/glance/files/openstack-glance-api
    - mode: 755
    - user: root
    - group: root

/etc/init.d/openstack-glance-registry:
  file.managed:
    - source: salt://openstack/glance/files/openstack-glance-registry
    - mode: 755
    - user: root
    - group: root

glance-service:
  cmd.run:
    - name: chkconfig --add openstack-glance-api && chkconfig --add openstack-glance-registry
    - unless: chkconfig --list | grep glance
    - require:
      - file: /etc/init.d/openstack-glance-api
      - file: /etc/init.d/openstack-glance-registry

glance-init:
  cmd.run:
    - name: glance-manage db_sync && touch /var/lock/glance-datasync.lock
    - require:
      - mysql_grants: glance-mysql
    - unless: test -f /var/lock/glance-datasync.lock

openstack-glance-api:
  service:
    - running
    - enable: True
    - watch: 
      - file: /etc/glance/schema-image.json
      - file: /etc/glance/policy.json
      - file: /etc/glance/logging.cnf
      - file: /etc/glance/glance-registry-paste.ini
      - file: /etc/glance/glance-api-paste.ini
      - file: /etc/init.d/openstack-glance-registry
      - file: /etc/glance/glance-api-paste.ini
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf
    - require:
      - cmd: glance-install
      - cmd: glance-service
      - cmd: glance-init

openstack-glance-registry:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/glance/schema-image.json
      - file: /etc/glance/policy.json
      - file: /etc/glance/logging.cnf
      - file: /etc/glance/glance-registry-paste.ini
      - file: /etc/glance/glance-api-paste.ini
      - file: /etc/init.d/openstack-glance-registry
      - file: /etc/glance/glance-api-paste.ini
      - file: /etc/glance/glance-api.conf
      - file: /etc/glance/glance-registry.conf
    - require:
      - cmd: glance-install
      - cmd: glance-service
      - cmd: glance-init


glance-data-init:
  file.managed:
    - name: /usr/local/bin/glance_data.sh
    - source: salt://openstack/glance/files/glance_data.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - defaults:
      ADMIN_PASSWD: {{ pillar['glance']['ADMIN_PASSWD'] }} 
      ADMIN_TOKEN: {{ pillar['glance']['ADMIN_TOKEN'] }}
      CONTROL_IP: {{ pillar['glance']['CONTROL_IP'] }}
  cmd.run:
    - name: bash /usr/local/bin/glance_data.sh && touch /var/lock/glance-datainit.lock
    - require:
      - file: glance-data-init
      - service: openstack-glance-api
      - service: openstack-glance-registry
    - unless: test -f /var/lock/glance-datainit.lock
