/root/.pip:
  file.directory:
    - user: root
    - group: root

compute-init:
  pkg.installed:
    - names:
      - gcc
      - python-pip
      - python-devel
      - libxslt-devel
      - MySQL-python
      - openssl-devel
      - libudev-devel
      - git
      - kernel
      - kernel-devel
      - wget
      - qemu-kvm
      - python-numdisplay
      - device-mapper
      - bridge-utils
  file.managed:
    - name: /root/.pip/pip.conf
    - source: salt://openstack/init/files/pip.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /root/.pip

messagebus:
  service.running:
    - name: messagebus
    - enable: True

libvirtd:
  file.managed:
    - name: /etc/libvirt/qemu.conf
    - source: salt://openstack/nova/files/qemu.conf
    - mode: 644
    - user: root
    - group: root
  pkg.installed:
    - names:
      - libvirt
      - libvirt-python
      - libvirt-client
  service.running:
    - name: libvirtd
    - enable: True

avahi-daemon:
  pkg.installed:
    - name: avahi
  service.running:
    - name: avahi-daemon
    - enable: True
    - require:
      - pkg: avahi-daemon

compute-pip-install:
  file.managed:
    - name: /usr/local/src/compute_pip.txt
    - source: salt://openstack/init/files/compute_pip.txt
    - mode: 644
    - uesr: root
    - group: root
  cmd.run:
    - name: pip install -r /usr/local/src/compute_pip.txt
    - require:
      - pkg: compute-init
      - file: compute-pip-install
