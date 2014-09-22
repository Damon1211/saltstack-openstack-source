neutron-install:
  file.managed:
    - name: /usr/local/src/neutron-2014.1.1.tar.gz
    - source: salt://openstack/neutron/files/neutron-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf neutron-2014.1.1.tar.gz && cd neutron-2014.1.1 && pip-python install -r requirements.txt && python setup.py install
    - unless: pip-python freeze | grep neutron==2014.1.1
    - require:
      - file: neutron-install
      - pkg: openstack-pkg-init
