include:
  - openstack.nova.nova_install
  - openstack.nova.nova_config

nova-compute-service:
  file.managed:
    - name: /etc/init.d/openstack-nova-compute
    - source: salt://openstack/nova/files/openstack-nova-compute
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: chkconfig --add openstack-nova-compute
    - unless: chkconfig --list | grep openstack-nova-compute
    - require:
      - file: nova-compute-service
  service.running:
    - name: openstack-nova-compute
    - enable: True
    - watch:
      - file: /etc/nova/api-paste.ini
      - file: /etc/nova/logging.conf
      - file: /etc/nova/policy.json
      - file: /etc/nova/rootwrap.conf
      - file: /etc/nova/nova.conf
      - file: /etc/nova/rootwrap.d
    - require:
      - cmd: nova-compute-service
      - file: /var/log/nova
      - file: /var/lib/nova/instances
