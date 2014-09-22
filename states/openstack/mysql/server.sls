mysql-server:
  pkg:
    - installed
  file.managed:
    - name: /etc/my.cnf
    - source: salt://openstack/mysql/files/my.cnf
    - require:
      - pkg: mysql-server
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - pkg: mysql-server
    - watch:
      - file: mysql-server
  cmd.run:
    - name: chkconfig --add mysql
    - unless: chkconfig --list | grep mysql
    - require:
      - pkg: mysql-server
