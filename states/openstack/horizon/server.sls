horizon-install:
  file.managed:
    - name: /usr/local/src/horizon-2014.1.1.tar.gz
    - source: salt://openstack/horizon/files/horizon-2014.1.1.tar.gz
    - mode: 644
    - user: root
    - group: root
  cmd.run:
    - name: cd /usr/local/src/ && tar zxf horizon-2014.1.1.tar.gz && cd horizon-2014.1.1 && pip-python install -r requirements.txt && python setup.py install
    - unless: pip-python freeze | grep horizon==2014.1.1
    - require:
      - file: horizon-install

horizon-init:
  cmd.run:
    - name: mv /usr/local/src/horizon-2014.1.1 /var/www/horizon-2014.1.1 && chown -R apache:apache /var/www/horizon-2014.1.1
    - require:
      - cmd : horizon-install
    - unless: test -d /var/www/horizon-2014.1.1

openstack_dashboard:
  file.managed:
    - name: /var/www/horizon-2014.1.1/openstack_dashboard/local/local_settings.py
    - source: salt://openstack/horizon/files/local_settings.py
    - user: apache
    - group: apache
    - template: jinja
    - defaults:
      CONTROL_IP: {{ pillar['horizon']['CONTROL_IP'] }}
    - require:
      - pkg: httpd

/etc/httpd/conf.d/horzion.conf:
  file.managed:
    - source: salt://openstack/horizon/files/horizon.conf
    - user: apache
    - group: apache
    - require:
       - pkg: httpd

/var/run/horizon:
  file.directory:
    - user: root
    - group: root

httpd:
  pkg.installed:
    - names:
      - httpd
      - mod_wsgi
  service:
    - running
    - enable: true
    - watch:
      - pkg: httpd
    - require:
      - file: /etc/httpd/conf.d/horzion.conf
      - file: openstack_dashboard
      - file: /var/run/horizon
