nova-install:
  file.managed:
    - name: /usr/local/src/nova-2014.1.1.tar.gz
    - source: salt://openstack/nova/files/nova-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf nova-2014.1.1.tar.gz && cd nova-2014.1.1 && pip-python install -r requirements.txt && python setup.py install
    - unless: pip-python freeze | grep nova==2014.1.1
    - require:
      - file: nova-install
      - pkg: openstack-pkg-init
