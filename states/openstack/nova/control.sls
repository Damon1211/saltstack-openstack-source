include:
  - openstack.nova.nova_install
  - openstack.nova.nova_config

nova-init:
  cmd.run:
    - name: nova-manage db sync && touch /var/lock/nova-dbsync.lock
    - require:
      - mysql_grants: nova-mysql
    - unless: test -f /var/lock/nova-dbsync.lock

/usr/local/bin/nova_data.sh:
  file.managed:
    - source: salt://openstack/nova/files/nova_data.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - defaults:
      ADMIN_PASSWD: {{ pillar['nova']['ADMIN_PASSWD'] }} 
      ADMIN_TOKEN: {{ pillar['nova']['ADMIN_TOKEN'] }}
      CONTROL_IP: {{ pillar['nova']['CONTROL_IP'] }}

nova-data-init:
  cmd.run:
    - name: bash /usr/local/bin/nova_data.sh && touch /var/lock/nova-datainit.lock
    - require:
      - file: /usr/local/bin/nova_data.sh
      - cmd: nova-init
    - unless: test -f /var/lock/nova-datainit.lock

nova-api-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-api
    - source: salt://openstack/nova/files/openstack-nova-api
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-api
    - unless: chkconfig --list | grep openstack-nova-api
    - require:
      - file: nova-api-service
  service.running:
    - name: openstack-nova-api
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-api-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances

nova-cert-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-cert
    - source: salt://openstack/nova/files/openstack-nova-cert
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-cert
    - unless: chkconfig --list | grep openstack-nova-cert
    - require:
      - file: nova-cert-service
  service.running:
    - name: openstack-nova-cert
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-cert-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances

nova-conductor-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-conductor
    - source: salt://openstack/nova/files/openstack-nova-conductor
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-conductor
    - unless: chkconfig --list | grep openstack-nova-conductor
    - require:
      - file: nova-conductor-service
  service.running:
    - name: openstack-nova-conductor
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-conductor-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances

nova-console-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-console
    - source: salt://openstack/nova/files/openstack-nova-console
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-console
    - unless: chkconfig --list | grep openstack-nova-console
    - require:
      - file: nova-console-service
  service.running:
    - name: openstack-nova-console
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-console-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances

nova-consoleauth-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-consoleauth
    - source: salt://openstack/nova/files/openstack-nova-consoleauth
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-consoleauth
    - unless: chkconfig --list | grep openstack-nova-consoleauth
    - require:
      - file: nova-consoleauth-service
  service.running:
    - name: openstack-nova-consoleauth
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-consoleauth-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances

novnc-install:
  file.managed:
    - name: /usr/local/src/novnc.tar.gz
    - source: salt://openstack/nova/files/novnc.tar.gz
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /usr/local/src && tar zxf novnc.tar.gz && mv novnc /usr/share/novnc
    - unless: test -d /usr/share/novnc
    - require:
      - file: novnc-install

nova-novncproxy-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-novncproxy
    - source: salt://openstack/nova/files/openstack-nova-novncproxy
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-novncproxy
    - unless: chkconfig --list | grep openstack-nova-novncproxy
    - require:
      - file: nova-novncproxy-service
  service.running:
    - name: openstack-nova-novncproxy
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-novncproxy-service
      - cmd: nova-data-init
      - cmd: novnc-install
      - file: /var/log/nova
      - file: /var/lib/nova/instances

nova-scheduler-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-scheduler
    - source: salt://openstack/nova/files/openstack-nova-scheduler
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-scheduler
    - unless: chkconfig --list | grep openstack-nova-scheduler
    - require:
      - file: nova-scheduler-service
  service.running:
    - name: openstack-nova-scheduler
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-install
      - cmd: nova-scheduler-service
      - cmd: nova-data-init
      - file: /var/log/nova
      - file: /var/lib/nova/instances
