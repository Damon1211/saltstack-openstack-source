include:
  - openstack.neutron.neutron_install
  - openstack.neutron.neutron_config
  - openstack.neutron.linuxbridge_agent

/usr/local/bin/neutron_data.sh:
  file.managed:
    - source: salt://openstack/neutron/files/neutron_data.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - defaults:
      ADMIN_PASSWD: {{ pillar['neutron']['ADMIN_PASSWD'] }} 
      ADMIN_TOKEN: {{ pillar['neutron']['ADMIN_TOKEN'] }}
      CONTROL_IP: {{ pillar['neutron']['CONTROL_IP'] }}

neutron-data-init:
  cmd.run:
    - name: bash /usr/local/bin/neutron_data.sh && touch /var/lock/neutron-datainit.lock
    - require:
      - file: /usr/local/bin/neutron_data.sh
    - unless: test -f /var/lock/neutron-datainit.lock

openstack-neutron-server:
  file.managed:
    - name: /etc/init.d/openstack-neutron-server
    - source: salt://openstack/neutron/files/openstack-neutron-server
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add openstack-neutron-server
    - unless: chkconfig --list | grep openstack-neutron-server
    - require:
      - file: openstack-neutron-server
  service.running:
    - enable: True
    - watch:
      - file: /etc/neutron/api-paste.ini
      - file: /etc/neutron/dhcp_agent.ini
      - file: /etc/neutron/policy.json
      - file: /etc/neutron/rootwrap.conf
      - file: /etc/neutron/rootwrap.d
      - file: /etc/neutron/neutron.conf
      - file: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
      - file: openstack-neutron-server
    - require:
      - cmd: neutron-data-init
      - cmd: openstack-neutron-server
      - file: /var/log/neutron
      - file: /var/lib/neutron

openstack-neutron-dhcp-agent:
  file.managed:
    - name: /etc/init.d/openstack-neutron-dhcp-agent
    - source: salt://openstack/neutron/files/openstack-neutron-dhcp-agent
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add openstack-neutron-dhcp-agent
    - unless: chkconfig --list | grep openstack-neutron-dhcp-agent
    - require:
      - file: openstack-neutron-dhcp-agent
  service.running:
    - enable: True
    - watch:
      - file: /etc/neutron/api-paste.ini
      - file: /etc/neutron/dhcp_agent.ini
      - file: /etc/neutron/neutron.conf
      - file: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
      - file: openstack-neutron-dhcp-agent
    - require:
      - cmd: openstack-neutron-dhcp-agent
      - file: openstack-neutron-dhcp-agent
