pip-dir:
  file.directory:
    - name: /root/.pip
    - user: root
    - group: root

openstack-pkg-init:
  pkg.installed:
    - names:
      - gcc
      - python-pip
      - python-devel
      - libxslt-devel
      - MySQL-python
      - openssl-devel
      - libudev-devel
      - wget
      - git
      - kernel
      - kernel-devel
      - libvirt-python
      - libvirt
      - qemu-kvm
      - python-numdisplay
      - device-mapper
      - bridge-utils
      - libffi
      - libffi-devel
  file.managed:
    - name: /root/.pip/pip.conf
    - source: salt://openstack/init/files/pip.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: pip-dir

control-pip-install:
  file.managed:
    - name: /usr/local/src/control_pip.txt
    - source: salt://openstack/init/files/control_pip.txt
    - mode: 644
    - uesr: root
    - group: root
  cmd.run:
    - name: pip install -r /usr/local/src/control_pip.txt
    - require:
      - pkg: openstack-pkg-init
      - file: control-pip-install
