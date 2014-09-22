cinder-install:
  file.managed:
    - name: /usr/local/src/cinder-2014.1.1.tar.gz
    - source: salt://openstack/cinder/files/cinder-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf cinder-2014.1.1.tar.gz && cd cinder-2014.1.1 && pip-python install -r requirements.txt && python setup.py install
    - unless: pip-python freeze | grep cinder==2014.1.1
    - require:
      - file: cinder-install
      - pkg: openstack-pkg-init
