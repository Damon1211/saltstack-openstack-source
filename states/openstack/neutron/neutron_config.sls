/var/log/neutron:
  file.directory:
    - user: root
    - group: root

/var/lib/neutron:
  file.directory:
    - user: root
    - group: root

/var/run/neutron:
  file.directory:
    - user: root
    - group: root

/etc/neutron/plugins/linuxbridge/:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/neutron/plugins/ml2/:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

/etc/neutron/api-paste.ini:
  file.managed:
    - source: salt://openstack/neutron/files/api-paste.ini
    - mode: 644
    - user: root
    - group: root

/etc/neutron/dhcp_agent.ini:
  file.managed:
    - source: salt://openstack/neutron/files/dhcp_agent.ini
    - mode: 644
    - user: root
    - group: root

/etc/neutron/policy.json:
  file.managed:
    - source: salt://openstack/neutron/files/policy.json
    - mode: 644
    - user: root
    - group: root

/etc/neutron/rootwrap.conf:
  file.managed:
    - source: salt://openstack/neutron/files/rootwrap.conf
    - mode: 644
    - user: root
    - group: root

/etc/neutron/rootwrap.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

neutron-rootwrap.d:
  file.recurse:
    - name: /etc/neutron/rootwrap.d
    - source: salt://openstack/neutron/files/rootwrap.d

/etc/neutron/neutron.conf:
  file.managed:
    - source: salt://openstack/neutron/files/neutron.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      RABBITMQ_HOST: {{ pillar['neutron']['RABBITMQ_HOST'] }}
      RABBITMQ_PORT: {{ pillar['neutron']['RABBITMQ_PORT'] }}
      RABBITMQ_USER: {{ pillar['neutron']['RABBITMQ_USER'] }}
      RABBITMQ_PASS: {{ pillar['neutron']['RABBITMQ_PASS'] }}
      AUTH_KEYSTONE_HOST: {{ pillar['neutron']['AUTH_KEYSTONE_HOST'] }}
      AUTH_KEYSTONE_PORT: {{ pillar['neutron']['AUTH_KEYSTONE_PORT'] }}
      AUTH_KEYSTONE_PROTOCOL: {{ pillar['neutron']['AUTH_KEYSTONE_PROTOCOL'] }}
      AUTH_ADMIN_PASS: {{ pillar['neutron']['AUTH_ADMIN_PASS'] }}
      CONTROL_IP: pillar['neutron']['CONTROL_IP'] }}
      MYSQL_SERVER: {{ pillar['neutron']['MYSQL_SERVER'] }}
      NEUTRON_USER: {{ pillar['neutron']['NEUTRON_USER'] }}
      NEUTRON_PASS: {{ pillar['neutron']['NEUTRON_PASS'] }}
      NEUTRON_DBNAME: {{ pillar['neutron']['NEUTRON_DBNAME'] }}

/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini:
  file.managed:
    - source: salt://openstack/neutron/files/plugins/linuxbridge/linuxbridge_conf.ini
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      VM_INTERFACE: {{ pillar['neutron']['VM_INTERFACE'] }}

/etc/neutron/plugins/ml2/ml2_conf.ini:
    file.managed:
    - source: salt://openstack/neutron/files/plugins/ml2/ml2_conf.ini
    - mode: 644
    - user: root
    - group: root

