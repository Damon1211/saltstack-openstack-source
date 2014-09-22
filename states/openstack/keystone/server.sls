keystone-install:
  file.managed:
    - name: /usr/local/src/keystone-2014.1.1.tar.gz
    - source: salt://openstack/keystone/files/keystone-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf keystone-2014.1.1.tar.gz && cd keystone-2014.1.1 && pip-python install -r requirements.txt && python setup.py install
    - unless: pip-python freeze | grep keystone==2014.1.1
    - require: 
      - pkg: openstack-pkg-init
      - file: keystone-install

/var/log/keystone:
  file.directory:
    - user: root
    - group: root

/var/run/keystone:
  file.directory:
    - user: root
    - group: root

/etc/keystone:
  file.directory:
    - user: root
    - group: root

/etc/keystone/logging.conf:
  file.managed:
    - source: salt://openstack/keystone/files/logging.conf
    - mode: 644
    - user: root
    - group: root

/etc/keystone/keystone-paste.ini:
  file.managed:
    - source: salt://openstack/keystone/files/keystone-paste.ini
    - mode: 644
    - user: root
    - group: root

/etc/keystone/policy.json:
  file.managed:
    - source: salt://openstack/keystone/files/policy.json
    - mode: 644
    - user: root
    - group: root

/etc/keystone/keystone.conf:
  file.managed:
    - source: salt://openstack/keystone/files/keystone.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      MYSQL_SERVER: {{ pillar['keystone']['MYSQL_SERVER'] }}
      KEYSTONE_PASS: {{ pillar['keystone']['KEYSTONE_PASS'] }}
      KEYSTONE_USER: {{ pillar['keystone']['KEYSTONE_USER'] }}
      KEYSTONE_DBNAME: {{ pillar['keystone']['KEYSTONE_DBNAME'] }}
      ADMIN_TOKEN: {{ pillar['keystone']['ADMIN_TOKEN'] }}


keystone-db-init:
  cmd.run:
    - name: keystone-manage db_sync && touch /var/lock/keystone-datasync.lock
    - require:
      - mysql_grants: keystone-mysql
      - cmd: keystone-install
    - unless: test -f /var/lock/keystone-datasync.lock

openstack-keystone:
  file.managed:
    - name: /etc/init.d/openstack-keystone
    - source: salt://openstack/keystone/files/openstack-keystone
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add openstack-keystone
    - unless: chkconfig --list | grep keystone
    - require:
      - file: openstack-keystone
  service.running:
    - enable: True
    - watch:
      - file: /etc/keystone/logging.conf
      - file: /etc/keystone/keystone-paste.ini
      - file: /etc/keystone/policy.json
      - file: /etc/keystone/keystone.conf
    - require:
      - cmd: keystone-install
      - cmd: keystone-db-init
      - cmd: openstack-keystone
      - file: /var/log/keystone

keystone-data-init:
  file.managed:
    - name: /usr/local/bin/keystone_data.sh
    - source: salt://openstack/keystone/files/keystone_data.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - defaults:
      ADMIN_PASSWD: {{ pillar['keystone']['ADMIN_PASSWD'] }} 
      ADMIN_TOKEN: {{ pillar['keystone']['ADMIN_TOKEN'] }}
      USER_PASSWD: {{ pillar['keystone']['USER_PASSWD'] }}
      CONTROL_IP: {{ pillar['keystone']['CONTROL_IP'] }}
  cmd.run:
    - name: sleep 10 && bash /usr/local/bin/keystone_data.sh && touch /var/lock/keystone-datainit.lock
    - require:
      - file: keystone-data-init
      - service: openstack-keystone
    - unless: test -f /var/lock/keystone-datainit.lock

/root/keystone_admin:
  file.managed:
    - source: salt://openstack/keystone/files/keystone_admin
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - defaults:
      ADMIN_PASSWD: {{ pillar['keystone']['ADMIN_PASSWD'] }}
      ADMIN_TOKEN: {{ pillar['keystone']['ADMIN_TOKEN'] }}
      CONTROL_IP: {{ pillar['keystone']['CONTROL_IP'] }}
