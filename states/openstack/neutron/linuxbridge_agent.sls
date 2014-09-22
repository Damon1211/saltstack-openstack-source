include:
  - openstack.neutron.neutron_install
  - openstack.neutron.neutron_config

openstack-neutron-linuxbridge-agent:
  file.managed:
    - name: /etc/init.d/openstack-neutron-linuxbridge-agent
    - source: salt://openstack/neutron/files/openstack-neutron-linuxbridge-agent
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: chkconfig --add openstack-neutron-linuxbridge-agent
    - unless: chkconfig --list | grep openstack-neutron-linuxbridge-agent
    - require:
      - file: openstack-neutron-linuxbridge-agent
  service.running:
    - enable: True
    - watch:
      - file: /etc/neutron/api-paste.ini
      - file: /etc/neutron/dhcp_agent.ini
      - file: /etc/neutron/policy.json
      - file: /etc/neutron/rootwrap.conf
      - file: /etc/neutron/rootwrap.d
      - file: /etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini
      - file: openstack-neutron-linuxbridge-agent
    - require:
      - cmd: openstack-neutron-linuxbridge-agent
      - file: /var/log/neutron
      - file: /var/lib/neutron
