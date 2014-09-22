glance-mysql:
  mysql_database.present:
    - name: {{ pillar['glance']['GLANCE_DBNAME'] }}
    - require:
      - service: mysql-server
  mysql_user.present:
    - name: {{ pillar['glance']['GLANCE_USER'] }}
    - host: {{ pillar['glance']['HOST_ALLOW'] }}
    - password: {{ pillar['glance']['GLANCE_PASS'] }}
    - require:
      - mysql_database: glance-mysql
  mysql_grants.present:
    - grant: all
    - database: {{ pillar['glance']['DB_ALLOW'] }}
    - user: {{ pillar['glance']['GLANCE_USER'] }}
    - host: {{ pillar['glance']['HOST_ALLOW'] }}
    - require:
      - mysql_user: glance-mysql
