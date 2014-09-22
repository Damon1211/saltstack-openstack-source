saltstack-openstack
===================

###使用Saltstack自动部署Openstack集群。

架构概述
========

**1.OpenStack架构**
![架构图](https://github.com/unixhot/saltstack-openstack/blob/master/openstack.jpg)  

**2.介绍**

1.每个服务均有一个SLS目录。每个目录下均有SLS和files目录。files目录放置源码包和配置文件。
2.每个服务均有一个Pillar文件，主要定义和配置相关的如IP地址、网络接口、用户名和密码等。

使用步骤
========

**1.下载SLS和源码安装包** 
```ObjectiveC
# git clone https://github.com/unixhot/saltstack-openstack
```

**2.修改Pillar目录的各个服务的配置**

**3.修改top.sls**

**All-In-One(所有服务均安装在一台服务器)**

```ObjectiveC
base:
  'openstack-node1.unixhot.com':
    - openstack.keystone.keystone
    - openstack.glance.glance
    - openstack.nova.nova_control
    - openstack.neutron.neutron_server
    - openstack.neutron.neutron_linuxbridge_agent
    - openstack.horizon.horizon
    - openstack.nova.nova_compute
``` 

**Cluster（一个控制节点，多个计算节点）**

```ObjectiveC
base:
  'openstack-node1.unixhot.com':
    - openstack.keystone.keystone
    - openstack.glance.glance
    - openstack.nova.nova_control
    - openstack.neutron.neutron_server
    - openstack.neutron.neutron_linuxbridge_agent
    - openstack.horizon.horizon
    
  'openstack-node2.unixhot.com':
    - openstack.nova.nova_compute
    - openstack.neutron.neutron_linuxbridge_agent
  
  'openstack-node3.unixhot.com':
    - openstack.nova.nova_compute
    - openstack.neutron.neutron_linuxbridge_agent
``` 


    
