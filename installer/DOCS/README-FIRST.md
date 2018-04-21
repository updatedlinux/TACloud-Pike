# Unattended Installer (Semi Automated) for OpenStack (PIKE)
Reynaldo R. Martínez P.
E-Mail: TigerLinux at Gmail dot com
Caracas, Venezuela.

## Introduction

This installer was made to automate the tasks of creating a virtualization infrastructure based on OpenStack. So far, There are 2 "flavors" for this installer: One for  Centos 7, and one for Ubuntu 16.04 LTS.

All versions produce a fully production-grade OpenStack installation. You can use this installer to make a single-node all-in-one OpenStack server, or a more complex design with controller and compute nodes. You can also use this installer (with small modifications made by yourself) in order to create a redundant infrastructure.

In summary, this installer can produce an OpenStack virtualization service completely usable in production environments, however, remember that the "bugs" factor don't depend solely on us. From time to time OpenStack packages can bring us some bugs too. We are using rpm/deb packages from Ubuntu and Redhat repositories and they can have their own bugs. 

## Using the Installer.

### First

* **READ, READ, READ and after some rest, READ AGAIN!.**

Read everything you can from **OpenStack** if you want to venture into the virtualization in the cloud World. If you do not like reading, then support yourself with someone who can do the reading and the understanding. Please do not try to use this Installer without having any knowledge at hand. View file `NOTES.txt` to understand a little more about the knowledge which you should have. In the `DOCS` directory you will find notes and other documentation usefull for you. Please read first, understand things, then act !.

And about the OpenStack documentation, you can begin here: [**OpenStack Documentation Site**](http://docs.openstack.org "OpenStack Documentation Site")

The big world of **OpenStack** includes several technologies from the world of Open-source and the world of networks that must be understood thoroughly before even attempting any installation of OpenStack, whether you use this installation tool or any other. In short, if you do not have the knowledge, do not even try. Gain the knowledge first, then proceed.

Before using the installer, you must prepare your server of servers. Again, in the file `NOTES.txt` you will find important points that you should understand before start an installation using this tool. The installer will make some validations, should yield negative results, will abort the process.

### Second: Edit the installer main configuration file.

First thing to do: Copy the **"main-config.rc"** file from **"sample-config"** directory to **"configs"** directory. Without the file "main-config.rc" in the proper directory (configs), the installer will not work.

The installer has a central configuration file: `./configs/main-config.rc`. This file is well documented so, if you did your homework and studied about OpenStack, you will know what to change there. There are very obvious things like passwords, IP addresses, modules to install and dns domains or domain names.

**NOTE:** At the very beginning of the config file, you'll find the following section:

```bash
#
# SECURITY CONFIGURATION
#
# Our OpenStack automated installer applies a lot of IPTABLES rules in order
# to protect critical services from outside interference.
# The following variables should be set accordingly to your network:
#
# All openstack endpoints will be opened to the following IP or Network.
# Example:
# osprivatenetwork="192.168.0.0/16"
# If you are installing an AIO public server (on packet.net or another datacenter
# using public IP's) set the variable to the server IP. This will ensure that all
# your primary services will be closed on only reacheable from inside the server
# providing and extra measure of protection.
# If you are installing a multi-server setup with a controller, computes, and storage
# nodes, set the variable to your private network where all your openstack nodes are
# connected. Example: osprivatenetwork="192.168.56.0/24"
# Please, never ever use "0.0.0.0/0" here
osprivatenetwork="192.168.56.60"
#
# Keystone is already exposed to the IP's or Network configured on the "osprivatenetwork"
# variable, but, you can expose all keystone endpoints (ports 5000 and 35357) to an
# additional admin network, or even "0.0.0.0/0" if you want your Keystone to be reacheable
# from all the world.
#
keystoneclientnetwork="192.168.56.60"
#
# Manila and Designate are already exposed to any IP or Net included on the
# "osprivatenetwork" variable. If you want to expose both Manila and Designate services
# to a specific/additional network, IP, or to all the world, set the following variables:
#
manilaclientnetwork="0.0.0.0/0"
designateclientnetwork="0.0.0.0/0"
#
# Finally, you normally want to expose Horizon to all your nets, but if you want to specicy
# a single specific administrative network, set the variable to your desired source net:
horizonclientnetwork="0.0.0.0/0"
```

**If you fail to properly configure those four variables (specially the one named "osprivatenetwork") you'll end with a non-working OpenStack system.**

In the version by default, the configuration file has selections modules to install what is known as an **"all-in-one"** (an OpenStack monolithic service with controller-compute capabilites). You can just change the IP with the one assigned to your server (please DO NOT use *localhost* and DO NOT use a Dynamic DHCP assigned IP).

Additionally, there are some modules that are in default "no":

* Swift.
* Trove.
* Sahara.
* Manila.
* Designate.
* Magnum.
* SNMP.

We recommend to activate swift install option "only If you are really going to use it". **Swift** alone is almost as extensive as OpenStack. Use if you REALLY know what you're doing and if you are REALLY going to use it. Remember the functions of all OpenStack modules:

* Keystone: Identity Service.
* Glance: Image Service.
* Cinder: Block Storage Service.
* Swift: Object Storage Service.
* Neutron: Networking Service
* Nova: Compute Service.
* Ceilometer: Telemetry Service.
* Aodh (installed along ceilometer): Alarming Service (needed if you want to create autoscaling groups with Heat Cloudformation).
* Gnocch (installed along ceilometer): Metric as a service.
* Heat: Orquestration/Cloudformation Service.
* Trove: Database Service (DBaaS).
* Sahara: Data Processing Service (Big Data).
* Manila: File Sharing as a Service.
* Designate: DNS as a Service.
* Magnum: Container infra as a Service.

The SNMP module installs usefull monitoring variables you can use in order to monitor OpenStack with SNMP but does not install any monitoring application. The variables are described (if you install the support) in `/etc/snmp/snmpd.conf`.

NOTE: Files for ZABBIX agent in the **"Goodies"** directory are also included.

If you want to install an **"all-in-one"** openstack service, only change passwords, IP addresses and mail domains and **dhcp/dnsmasq** info appearing in the configuration file.

After updating the configuration file, run at the root of directory script the following command:

```bash
./main-installer.sh install
```

The installer asks if you want to proceed (y/n).

If you run the installer with the additional parameter * auto * , it will run automatically without asking you confirmation. Example:

```bash
./main-installer.sh install auto
```

You can save all outputs produced by the installer using the tool `tee`. Example:

```bash
./main-installer.sh install | tee -a /var/log/my_log_de_install.log
```

## Controlling the installer behavior

As mentioned before, you can use this installer for more complex designs. Example:

* A single all-in-one monolithic server
* A cloud with a controller-compute and several compute nodes
* A cloud with a pure controller and several compute nodes
* A combination of the above and multiple storage nodes

As mentioned initially, you can use this installer with few modifications if you want to create a redundante system (two controllers with High Availability). See the following link in order to see what is required from you for this task:

**http://docs.openstack.org/ha-guide/**

### Controller node:

If your controller node will include a compute service (controller + compute, or an all-in-one server), the following variable in the configuration file must be set to "no":

```bash
nova_without_compute="no"
```

If you use ceilometer in the controller, and likewise the controller includes compute service, the following variable must also be set to "no":

```bash
ceilometer_without_compute="no"
```

However, if you are installing a "pure" controller (without compute service) set the following variables to "yes":

```bash
nova_without_compute="yes"
ceilometer_without_compute="yes"
```

### Compute nodes:

For the compute nodes, you must set to "yes" (this is mandatory) the installation variables for Nova and Neutron modules. The remaining modules (glance, cinder, horizon, trove, sahara and heat) must be set to "no". If you are using Ceilometer in the controller, you also must set it's installation variable to “yes” along with the ones for Nova and Neutron. In Addition, the following variables in sections of nova and neutron must be set to "yes":

```bash
nova_in_compute_node="yes"
neutron_in_compute_node="yes"
```

And if you are using ceilometer also the following variable must be "yes" for compute nodes:

```bash
ceilometer_in_compute_node="yes"
```

You must place the IP's for the services running in the controller (neutron, keystone, glance and cinder) and the Ip's for the Database and message broker backends. This is valid for either a controller or a compute:

```bash
novahost="Controller IP Address"
glancehost="Controller IP Address"
cinderhost="Controller IP Address"
neutronhost="Controller IP Address"
keystonehost="Controller IP Address"
messagebrokerhost="Message Broker IP Address"
dbbackendhost="Database Server IP Address"
vncserver_controller_address | spiceserver_controller_address = "Controller IP Address"
```

If you use ceilometer, the same case applies:

```bash
ceilometerhost="Controller IP Address"
```

For compute nodes, you must place the following variables with the IP in the compute node:

```bash
neutron_computehost="Compute Host IP Address"
nova_computehost="Compute Host IP Address "
```


### Cinder complex setups with multiple storage nodes.

This installer, in it's default form, will create a single cinder node that is both "cinder controller" and "cinder storage node". You can change this behaviour and install several additional storage nodes by modifying the following variables in the installer you run our your nodes:

#### First node: "all-in-one" cinder node or "dedicated controller" node.

Always install your all-in-one or dedicated controller node first.

If your node is an "all-in-one", let the variables in the cinder section on the main-config as they are and only modify the sections for your lvm/nfs/gluster backends if aplicable.

If your node is a "dedicated controller", first thing to do is change "cindernodetype" variable to "controller":

```bash
cindernodetype="controller"
```

Set the variables "cinderconfigglusterfs", "cinderconfiglvm" and "cinderconfignfs" to "no":

```bash
cinderconfiglvm="no"
cinderconfigglusterfs="no"
cinderconfignfs="no"
```

Set the variables "cinderhost" and "cindernodehost" to the same IP, in this case, the IP of your "cinder controller or all-in-one" node. Example:

```bash
cinderhost="192.168.56.60"
cindernodehost="192.168.56.60"
```

Finally, set your "default_volume_type" variable to the backend you want to consider "your default". Take note on the following: This installer will create the backend names in the form: type-IP where type is on of "lvm", "nfs", and "glusterfs", and IP is the node IP where the backend is located. By default, if the node you are configuring is the first-and-only "all-in-one" node, and you are configuring nfs, lvm and/or glusterfs, you can choose one of them as your default_volume_type. Example:

```bash
default_volume_type="lvm-192.168.50.60"
```

But, if you are configuring a dedicated cinder controller without storage, and your next node is a storage one with, by example, IP 192.168.60.61, and your only backend there is "nfs", you should configure your "default_volume_type" to:

```bash
default_volume_type="nfs-192.168.50.61"
```

#### Additional nodes: dedicated storage nodes.

Again: Always install your all-in-one or dedicated controller node first. If you fail to do this properly, you'll be unable to add storage nodes.

First thing to do in your installer at your dedicated storage node is set the following variable to "storage":

```bash
cindernodetype="storage"
```

Second thing is to adjust the following variables. Teh first one (cinderhost) is the IP of your all-in-one or dedicated-controller cinder server. The second IP (cindernodehost) is the IP of the dedicated storage node you are currently configuring. Example here, where your controller-or-all-in-one is 192.168.56.60 and the storage node you are currently installing is 192.168.56.61:

```bash
cinderhost="192.168.56.60"
cindernodehost="192.168.56.61"
```

After configuring this, you can set your backends (nfs, lvm, glusterfs, or none).

Set the variable "default_volume_type" the same as in your first cinder node (the one you installed as controller or all-in-one). This variable must be set the same along all your cinder servers (controller or all-in-one and storage nodes):

```bash
default_volume_type="nfs-192.168.50.61"
```


### Database Backend

The installer has the ability to install and configure the database service, and also it will create all the databases. This is completely controllable by the configuration file through the following variables:

```bash
dbcreate="yes"
dbinstall="yes"
dbpopulate="yes"
```

With these three options set to "yes", the database software is installed, will be configured and databases will be created using all the information contained in the configuration file.

Also, set a realistic value for "dbmaxcons" setting (maximun database connections). If your controller have a lot of cores, most controller components will spawn a lot of childrens, each with it's own database connection. See the notes in the config file about recommended settings for this value.

```bash
dbmaxcons=1000
```

Our default value is 1000, but this can fall short if your controller have a lot of cores. If you want to play safe, set a very high value here and later (after install) lower your database "max_connections" settings in order to set to more appropiate value.

> **WARNING**: If you choose these options, you must ensure that there is
> NO database software previously installed or the process will fail.

In our installation tool, you can choose to install and/or use between MySQL-based and PostgreSQL-based engines. For the MySQL-Based we really use MariaBD (if the installer installs the database engine and mysql is selected as backend). Please note that along openstack release history, some "strange things" had happened when postgresql is used as database backend. We really recommend using MariaDB (MySQL-Based) database backends in OpenStack production environments. At the end is up to you what backend to use, but be warned: If something gets broken with postgresql, it's not our fault !.

If you prefer to “not install” any database software because you already have one installed somewhere else (a database farm), and also have the proper administrative access to the database engine, set the variables as follows:

```bash
dbcreate="yes"
dbinstall="no"
dbpopulate="yes"
```

With this, the database software will not be installed, but it's up to you (or your **DBA**) to ensure you have full administrative access to create and modify databases in the selected backend.

If you do not want to install database software nor create databases (we assume that you already have previously created then in a farm or a separate server or even manually in the controller) set the three values "no":

```bash
dbcreate="no"
dbinstall="no"
dbpopulate="no"
```

In any case, always remember to properly set the database-control variables inside the installer configuration file.


### Default domain, admin user and password.

By default, the default domain is "**default**", the admin user is "**admin**", and it's password is the same you choose in the main-config.rc file when setting the variable "**keystoneadminpass**". In our default config file, the variable is set to the password "0p3nsT4ck":

```bash
keystoneadminpass="0p3nsT4ck"
```

Whatever you set in the "keystoneadminpass" variable, will be your "admin" password !.


### Protected config options.

Please note something. In our **main-config.rc** file you'll find this:

```bash
# PROTECTED KEYSTONE CONFIG OPTIONS - DO NOT CHANGE !!!
#
keystoneadminuser="admin"
keystoneservicename="keystone"
keystoneadmintenant="admin"
keystoneservicestenant="services"
keystonememberrole="_member_"
keystoneuserrole="user"
keystonedomain="default"
keystonereselleradminrole="ResellerAdmin"
keystone_admin_rc_file="/root/keystonerc_admin"
keystone_fulladmin_rc_file="/root/keystonerc_fulladmin"
#
# END OF PROTECTED KEYSTONE CONFIG OPTIONS 
```

Those settings are protected for a reason: If you change them, you'll break the OpenStack security policies, and this installation tool !. NEVER EVER Change those options, or your OpenStack installation will break !.


### Gnocchi instead of MongoDB

From OpenStack RELEASE 15, gnocchi is being set as metric service. No more mongodb !. Take into account that this eliminates any chance of using old "ceilometer client" to get metrics. Instead, use "openstack" client. Example:

```bash
openstack metric metric list
```

The command above is the equivalent to old "ceilometer meter-list" command. As a result of this change, Horizon (OpenStack WEB Dashboard) is unable to show the metrics. This time you should rely on tools like grafana. More information on the following link:

- http://gnocchi.xyz/3.1.0/grafana.html


### Cells setup is now mandatory.

Another important change from RELEASE 15, is CELLS setup, that is now mandatory. This aslo mean that, every time you add a new compute node in your OpenStack cloud, you need to run the following command in the NOVA controller:

```bash
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
```


### RPC Messaging backend (Message Broker)

As part of the components to install and configure, the installer installs and configure the software for **AMQP** (the **Message Broker**). This step *IS* mandatory for a controller or **all-in-one** OpenStack server. If your server or servers have a message broker already installed, conflicts can occur that prevent the correct operation of the installation.

Again, the installer configuration file will control which AMPQ service to install and configure. In earlier releases (up to Liberty) we provided two options for AMPQ: RabbitMQ and Qpid. From Mitaka, we are allowing only RabbitMQ. In the practice, this is by far the best and most recommended option for OpenStack.

Note something for your general knowledge: As recommended on most cloud implementations, **OpenStack** uses the "decoupled model", where, every component is running as microservices and agents. Those components communicate with each other by using a message broker. This is the right way to go in the Cloud.


### Console Manager (NOVNC / SPICEHTML5)

Through a configurable option in the installer configuration file (**consoleflavor**), you can choose between NoVNC and SpiceHTML5. If you want to eventually use SSL for the Dashboard, please leave the default (novnc) as it easier to configure with SSL.


### Cloudformation and AutoScaling

If you want to use Cloudformation with AutoScaling, you MUST install **"heat"**, **"ceilometer"** and **"aodh"** (**ceilometer/aodh alarms**):

```bash
heatinstall="yes"
ceilometerinstall="yes"
ceilometeralarms="yes"
```

NOTE: From **"OpenStack Release 13"**, ceilometer alarms is controlled by **"aodh"** module. This installer install and configure aodh along ceilometer components from inside ceilometer installation module. Please note that, because from Release 15 gnocchi is being used instead of mongodb, you need to adapt your autoscaling templates accordingly.


### Trove

If you choose to install trove, this installation tool will install and configure all the software needed, but IT WILL NOT configure trove-ready images. That's part of your tasks as a Cloud Administrator. Please follow recomendations from the community regarding proper-configured glance images for trove. The "very big secret" of proper trove deployment is the glance-image. Fail to do that properlly, and forget about trove working
the way it should.

Tips for a properlly working trove image:

- Cloud init must be installed on the image and configured for start at boot time. Please eliminate "mounts" from /etc/cloud/cloud.cfg or your vm will try to auto-mount the ephemeral disk. This can interfere with trove guest agent activities.
- The trove guest agent MUST BE installed and configured in the image. Also, give sudo root-powers to the "trove" account on the glance image. The guest agent perform some changes in the vm that requires root access. The trove guest agent (if installed from ubuntu/centos repositories) uses a "trove" account to run.
- Install the database engine software in the glance image too. Trove guest agent can do this for you in many ways too.
- TRICK: You can install the guest agent, configure it, create the "sudo" permissions, and install the database software vía Cloud init. You just need to create a file /etc/trove/cloudinit/DATASTORE-NAME.cloudinit (sample: /etc/trove/cloudinit/mysql.cloudinit) with the commands needed to do everything. This file can be any script-based languaje (sh, bash, etc.).
- Flavors: If you plan to use locally-based storage for trove (instead of cinder-based), remember to choose a flavor for your database services that contains an ephemeral disk. Trove requires an extra disk for the database storage.

Finally, note about swift: Trove requires swift for it's replicas and backups functions, so, if you want replicas of backups, ensure to install swift in your cloud.


### Manila

If you choose to install manila, this installation tool will install and configure all the software needed, and also, it will configure the LVM based backend, if you choose to use that backend. As a requirement, the LVM backend need a previouslly configured LVM group (same case as Cinder using LVM). By default, our main config names this volume group "manila-volumes" but yoy can change it in the config. Remember to create the LV if you plan to include Manila with LVM backed storage:

```bash
pvcreate /dev/sde
vgcreate manila-volumes /dev/sde
```

Another example with an free /dev/sde3 partition:

```bash
pvcreate /dev/sde3
vgcreate cinder-volumes /dev/sde3
```


### Designate

EXPERIMENTAL: We are including "experimental support" for Designate (DNS as a Service) in our installer. By the moment we are only using BIND 9 backend. Our designate module install everything you need to fully operate designate with a BIND 9 backend and software installed in the server, and even gives you the option of integrate designate with nova and neutron for automatic record creation for floating IP's and Fixed IP's. If you read designate documentation, you can add other BIND 9 servers and control them with designate OpenStack service. Remember: This is still experimental.

More information about designate:

* http://docs.openstack.org/developer/designate/


### Magnum

"Container as a Service" OpenStack solution (known as MAGNUM) is included in our installer too. Note that, like trove, we setup the service but do not include the service images. This is a task for the OpenStack administrator. More information can be obtained from the link:

- https://docs.openstack.org/magnum/pike/user/index.html
- https://docs.openstack.org/project-install-guide/container-infrastructure-management/ocata/launch-instance.html

Notes about component requirements: Magnum requires HEAT. It WONT WORK without HEAT !. Also, for cluster containers based on swarm and kubernetes, you'll need cinder-based persistent storage. If you also set your cluster templates with a local registry, you'll need swift too.


### Support Scripts installed with this solution

This installer will place a OpenStack Services control script in the “/usr/local/bin” path:

```bash
openstack-control.sh OPTION [component]
```

The script uses the following options:

1. **enable**: Enables the services to start at boot time.
2. **disable**: disable services start at boot time.
3. **start**: starts all services.
4. **stop**: stops all services.
5. **restart**: restart all services.
6. **status**: displays the status of all services.

NOTE: We used or best judgment to ensure the proper start/stop order in the openstack-control.sh script. That being said, you could benefit a lot by using this script to control you cloud instead of the order normally set by “init”, “systemctl” or “upstart”. A good choice can be to place the script inside rc.local file. Your choice.

**IMPORTANT NOTE**: Again, We recommend using the openstack-control.sh script to initialize all OpenStack services!. Put all openstack services in "disable" state with "openstack-control.sh disable" and call the script with the "start" option from inside the /etc/rc.local file:

```bash
/usr/local/bin/openstack-control.sh start
```

This script is included by the installer in every single OpenStack node (controller and compute nodes)

You can also control individual OpenStack modules with the script:

```bash
/usr/local/bin/openstack-control.sh OPTION MODULE
```

Samples:

```bash
/usr/local/bin/openstack-control.sh start nova
```

```bash
/usr/local/bin/openstack-control.sh restart neutron
```

```bash
/usr/local/bin/openstack-control.sh status cinder
```

By the moment, we support the following modules:

- keystone
- swift
- glance
- cinder
- neutron
- nova
- ceilometer
- heat
- trove
- sahara
- manila
- designate
- magnum

**NOTE: aodh (Ceilometer Alarming) and gnocchi (metric as a service) are managed inside "ceilometer" option, so if you call "openstack-control.sh ACTION ceilometer", the "ACTION" (stop/start/enable/disable/etc) will be applied to both ceilometer and aodh services. Also, note that both gnocchi-api and aodh-api are mod-wsgi-based (apache) services. If you stop ceilometer using "openstack-control.sh", you will actually stop apache and all related services working trough it (keystone included). Also, in ubuntu 1604lts, cinder-api works trough apache mod-wsgi.**

```bash
openstack-log-cleaner.sh
```

The installer will place a script “openstack-log-cleaner.sh” in the path “/usr/local/bin” that have the ability to “clean” all OpenStack related logs.

This script is called during the final phase of installation to clean all logs before leaving the server installed and running for the very first time, but can also be used by you “Cloud Administrator” to clean all OpenStack related logs whenever you consider it necessary.

```bash
compute-and-instances-full-report.sh
```

This script is copied by the installer onto /usr/local/bin directory. The function of this script is give a report of all compute nodes in the openstack cloud and it's related virtual machines (instances) including the IP or IP's assigned to the instances.

```bash
instance-cpu-metrics-report.sh
```

This script is copied by the installer onto /usr/local/bin directory. The function of this script is give a report of all instances and their CPU usage (in percents). Please note that this script requires Ceilometer installed in order to function.

NOTE: The "instance-cpu-metrics-report.sh" script has been modified in order to work with gnocchi metrics. For help about the new options supported by the script, run:

```bash
instance-cpu-metrics-report.sh --help
```

### SYSTEMD "All-Services" control daemon.

During the postinstall stage, a "systemd" service named "openstack-automated.service" (or openstack-automated for short) is created and activated. This service is configured to start after networking and rc-local/rc.local are started. The service usrs "openstack-control.sh" script described above in order to start/stop all openstack services.

Because this systemd based service is enabled at postinstall time, this will ensure that your openstack installation boot in the most correctly way possible when your system starts. If you want to disable OpenStack autostart at boot-time, just run the following command:

```bash
systemctl disable openstack-automated.service
```

You can use "start", "stop", "disable", "enable" and "status" on this service too in order to start, stop, disable, enable or "see status" of the openstack services. The "status" option is very basic. For a more detailed view, use "openstack-control.sh" status.


### More about apache and mod-wsgi.

It's a trend !. OpenStack group is gradually migrating all it's API's services (all services exposing a REST interface) to mod-wsgi trough apache. That means in practical terms, that if you stop apache, several api services will stop working. The afected services are (by the moment):

- keystone.
- cinder-api (only in ubuntu 1604lts packages).
- aodh-api.
- gnocchi-api.
- nova-placement-api.

Eventually all API's will reside inside apache (or nginx) trough any mod-wsgi solution. Please take this into consideration when doing anything with apache.


### Keystone Environment Admin Variables

This installer will place the following files in your OpenStack Nodes:

```bash
/root/keystonerc_admin
/root/keystonerc_fulladmin
```

Those files include your "admin" credentials (user/password included) along the URL endpoints for Keystone Service. The file first file use the normal public endpoint at port 5000. The second one, uses the full admin port 35357.

Sourcing the "keystonerc_admin" file in your environment will allow you to perform normal administration tasks, not included the ones related to keystone advanced tasks. Sourcing the "keystonerc_fulladmin" file in your environment will give you "super cow god-like powers" over your cloud installation.

Then:

Normal admin tasks:

```bash
source /root/keystonerc_admin
```

Super-cow god-like powers:

```bash
source /root/keystonerc_fulladmin
```


### STARTING VIRTUAL MACHINES AVOIDING I/O STORMS

If you suffer a total blackout and your cloud service goes completely down, and then try to start it including all virtual machines (instances), chances are that you will suffer a I/O storm. That can easily collapses all your servers or at least slow them down for a while.

We include a script called “openstack-vm-boot-start.sh” that you can use to start all your OpenStack VM's (instances) with a little timeout between each virtual machine. You need to include the name or UUID of the instances that you want to start automatically in the following file:

```bash
/etc/openstack-control-script-config/nova-start-vms.conf
```

Place the script in the rc.local file ONLY in the controller node.

NOTE: The names of the VMs must be obtained from "nova list" command.


### DNSMASQ

Neutron dhcp-agent uses **DNSMASQ** for IP assignation to the VM's (instances). We include a customized dnsmasq-control file with some samples that you can use to fine-tune your dhcp-agent:

```
/etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
```

There are commented examples in the file. Use these examples to pass options to
different instances of dnsmasq created for each subnet where you select the option to use **dhcp**.

Recommendation: Try to have a good **DNS** structure for your cloud.


### Installer modularization

While the main setup process "**main-installer.sh**" is responsible for calling each module of each installer component, these modules are really independent of one another, to the point that they can be called sequentially and manually by you. Is not the common case, but can be done. The normal order of execution for each module is as follows (assuming that all components will be installed):

* requeriments.sh
* messagebrokerinstall.sh
* databaseinstall.sh
* requeriments-extras.sh (only present for Ubuntu based installations)
* keystoneinstall.sh
* keystone-XXXX (where XXXX is: swift, glance, cinder, neutron, nova, ceilometer, heat, trove, sahara, manila, designate, and magnum).
* swiftinstall.sh
* glanceinstall.sh
* cinderinstall.sh
* neutroninstall.sh
* novainstall.sh
* ceilometerinstall.sh
* heatinstall.sh
* troveinstall.sh
* saharainstall.sh
* manilainstall.sh
* designateinstall.sh
* magnuminstall.sh
* snmpinstall.sh
* horizoninstall.sh
* postinstall.sh


Then again, we do not recommend to run those modules out of the main installer, unless of course you know exactly what you are doing.


### RECOMMENDATIONS FOR INSTALLATION IN CENTOS AND UBUNTU SERVER.

#### Centos 7:

1. Install Centos with the selection of packages for "Infrastructure Server". Make sure you have properly installed and configured both SSH and NTP. Ntpdate is also recommended. Again, a proper DNS infrastructure is very recommended.

2. Add the EPEL and RDO repositories (see "NOTES.txt").

3. Install and configure OpenVSWitch (again, see "NOTES.txt").

**WARNING**: OpenStack does not support MySQL lower than 5.5. See notes and take proper steps. If you use our installation tool in order to install database support, we will install MariaDB 10 directly obtained from RDO repositories.

IMPORTANT NOTE: The installer disables Centos 7 SELINUX. We had found some bugs, specially when using PostgreSQL and with some scenarios with NOVA-API.

#### ELREPO Kernel for Centos 7.

If you plan to use Centos 7, please please please please use the "kernel-ml" from ELREPO.ORG. More instructions on the following link:

- http://elrepo.org/tiki/kernel-ml

#### Ubuntu 16.04 LTS:

1. Install Ubuntu Server 16.04 LTS standard way and select as an additional package "OpenSSH Server". Install and configure the ntpd service. Also SSH. It is also recommended to use ntpdate.

2. Install and configure OpenVSWitch (see "NOTES.txt").

As you can see in all cases, NTP and SSH are very important. Fail to configure those services correctly, and prepare to have a live full of misery.


### What about Debian ?:

We supported debian meanwhile it was proper documentation available for this distro on docs.opentstack.org. We tried to include it again in Liberty, but after some research found most "real world" OpenStack deployments are using Ubuntu server as first option and Centos as second option with other distros lagging way behind ubuntu and centos. This convinced us about the futility of continuing any work on a Debian based OpenStack installer... at least up to Mitaka.

From RELEASE 14, Debian8-based installation documentation was included in docs.openstack.org. We'll reconsider if is worth the extra-work to include again Debian in our installers.


### Cinder:

If you are using CINDER with lvm-iscsi, be sure to have a free partition or disk to create a LVM called "cinder-volumes". Example (free disk /dev/sdc):

```bash
pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdc
```

Another example with an free /dev/sda3 partition:

```bash
pvcreate /dev/sda3
vgcreate cinder-volumes /dev/sda3
```

NOTE: If you plan to use Cinder just for learning/lab purposes, you always can create a "loop device based" disc. It's completelly up to you.

Our installer also can automate Cinder configuration for NFS and GlusterFS backends. See the main-config.rc file for more information.


### Swift:

If you are going to use swift, remember to have the disk/partition to be used for swift mounted on a specific directory that also should be indicated in the Installer main configuration file (main-config.rc).

example:

Variable `swiftdevice ="d1"`

In the fstab "d1" must be mounted as follows:

```
/dev/sdc1 /srv/node/d1 ext4 acl,user_xattr 0 0
```

In this example, we assume that there is an already formatted "/dev/sdc1" partition. You MUST use a file system capable of ACL and USER_XATTR. That being said, we recommend EXT4 or XFS or similar file systems.

NOTE: If you plan to use Swift just for learning/lab purposes, you always can create a "loop device based" disc. It's completelly up to you.


### Architecture:

Whether you use Centos or Ubuntu, you must choose to use 64 bits (amd64 / x86_64). Do not try to install OpenStack over 32 bits systems. Repeat after us at least one hundred tims: **"I will never ever try to install OpenStack on a 32 bits O/S"**.


### NTP Service:

We cannot stress enough so VITAL it is to have all the servers in the OpenStack cloud properly time synchronized. Read the documentation of OpenStack to know more about it, but if you are an I.T. professional, you should know how important it is to have all your datacenter equipment properlly ntp-synchronized, specially, cluster services.


### Recommendations for Virtualbox.

You can use this installer inside a VirtualBox VM if you want to use it to practice and learn OpenStack. The VirtualBox VM should have a "minimum" of 1GB's of RAM but for better results try to ensure 2GB's of RAM for the VM. A 4 GB's RAM VM is better if you want to include services like swift or trove. A full-service all-in-one OpenStack could require more. 8 GB's RAM based VirtualBox VM is a more "realistic" mini-lab if you want to explore OpenStack without having to dedicate a real server.


### Hardware recommendations for a VirtualBox VM:

Hard disks: one for the operating system (16 GB minimum's), one for Cinder-Volumes and another for swift. At least 8GB's for each disk (SWITF and cinder-volumes). 
Network: three interfaces:
Interface 1 in NAT mode for Internet Access.
Interface 2 in "only host adapter” mode, “PROMISC option: all". Suggestion: Use vboxnet0 with the network 192.168.56.0/24 (disable dhcp at virtualbox) and assign the IP 192.168.56.2 to the interface (the IP 192.168.56.1 will be on the real machine).
Interface 3 in "only host adapter” mode, “PROMISC option: all". Suggestion: Use vboxnet1 with the network 192.168.57.0/24 (disable dhcp at virtualbox). This will be assigned to the VM's network inside OpenStack in the eth2 interface and IP range 192.168.57.0/24 (the IP 192.168.57.1 will be in the real machine).

Make the O/S installation using the first disk only (the second and third ones will be used for cinder-volumes and swift). Add the openstack repositories (remember to see **NOTES.txt**), make the proper changes inside the installer configuration file, create the cinder volume as follows:


```bash
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
```

If you are using swift, create the partition on the third disk (/dev/sdc1) and mount it according to the notes in this document.

Make the installation indicating that the bridge Mapping (within main-config.rc) is:

```bash
bridge_mappings = "public:br-eth2"
```

Copy the `main-config.rc` file from the sample-config directory to config directory.

Change IP in the `main-config.rc` to the IP assigned to the VM inside the network 192.168.56.0/24 (sample: 192.168.56.2).

Run the installer.

enjoy:-)

You can enter the web server via the interface 192.168.56.x in order to run OpenStack management tasks. Create the subnet in the range of eth2 (192.168.57.0/24) and may enter the VM's OpenStack from real machine that will interface 192.168.57.1.

From outside VirtualBox you can enter to the Horizon web Interface by using the vboxnet0 assigned IP (192.168.56.2) and to the OpenStack VM instances running inside vboxnet1 network (192.168.57.0/24).


### Uninstalling

The main script also has a parameter used to completely uninstall OpenStack:

```bash
./main-installer.sh uninstall
```
or

```bash
./main-installer.sh uninstall auto
```

The first way to call the uninstall process asks you "y/n" for continue or abort, but if you called the script with the extra "auto" setting, it will run without asking anything from you and basically will erase all that it previously installed.

It is important to note that if the dbinstall="yes" option is used inside the installer configuration file, the uninstaller will remove not only the database engine but also all created databases.

If you DON'T WANT TO REMOVE the databases created before, modify the "main-config.rc" and set the dbinstall option to “no”. This will make the preserve the databases.

WARNING: If you are not careful, could end up removing databases and losing anything that you would like to backup. Consider yourself warned!.

This is very convenient for a reinstall. If for some reason your OpenStack installation needs to be rebuilt without touching your databses, uninstall using dbinstall = "no" and when you are going to reinstall, place all database options in "no" to preserve both the engine and all its created databases:

```bash
dbcreate="no"
dbinstall="no"
dbpopulate="no"
```

If your system has multiple nodes (controller / compute) use the
`main-config.rc` originally used to install each node in order to uninstall it.


### Goodies

In the * Goodies * directory you will find some scripts (each with their respective readme). You can use with those scripts as you see fit with your OpenStack installation. View the scripts and their respective "readme files" to better understand how to use them!.


### END.-
