#!/bin/bash
#
# Unattended/SemiAutomatted OpenStack Installer
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# OpenStack PIKE for Centos 7
#
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#
# First, we source our config file and verify that some important proccess are 
# already completed.
#

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't access my config file. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "DB Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "DB Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Keystone Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "Keystone Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/horizon-installed ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi


echo ""
echo "Installing Horizon Packages"

#
# We proceed to install dashboard and dependencies - that includes apache
#

yum install -y memcached python-memcached openstack-dashboard httpd

if [ $troveinstall == "yes" ]
then
	yum install -y openstack-trove-ui
fi

if [ $saharainstall == "yes" ]
then
	yum install -y openstack-sahara-ui
fi

if [ $manilainstall == "yes" ]
then
	yum install -y openstack-manila-ui
fi

if [ $magnuminstall == "yes" ]
then
	yum install -y openstack-magnum-ui
fi

if [ $neutroninstall == "yes" ]
then
	yum install -y openstack-neutron-lbaas-ui
fi

echo ""
echo "Done"
echo ""

source $keystone_admin_rc_file

echo "Configurig Horizon"

#
# We proceed to use sed and other tools in order to configure Horizon
# For the moment, the horizon config is python based, not ini based so
# we can use openstack-config/crudini or any other python based "ini"
# tool - that may change in the near future
#

mkdir -p /etc/openstack-dashboard
cp /etc/openstack-dashboard/local_settings /etc/openstack-dashboard/local_settings.ORIGINAL-CENTOS7
#
# BugFIx - October 09, 2017
# Dashboard Centos 7.4 FIX
cat /etc/httpd/conf.d/openstack-dashboard.conf > /root/openstack-dashboard.conf.original
cat ./libs/horizon/openstack-dashboard.conf > /etc/httpd/conf.d/openstack-dashboard.conf
# End of FIX
# 

cat ./libs/local_settings >  /etc/openstack-dashboard/local_settings

mkdir /var/log/horizon > /dev/null 2>&1
chown -R apache.apache /var/log/horizon

sed -r -i "s/CUSTOM_DASHBOARD_dashboard_timezone/$dashboard_timezone/" /etc/openstack-dashboard/local_settings
sed -r -i "s/CUSTOM_DASHBOARD_keystonehost/$keystonehost/" /etc/openstack-dashboard/local_settings
sed -r -i "s/CUSTOM_DASHBOARD_SERVICE_TOKEN/$SERVICE_TOKEN/" /etc/openstack-dashboard/local_settings
sed -r -i "s/CUSTOM_DASHBOARD_keystonememberrole/$keystonememberrole/" /etc/openstack-dashboard/local_settings
sed -r -i "s/OSINSTALLER_KEYSTONE_MEMBER/$keystonememberrole/" /etc/openstack-dashboard/local_settings

if [ $vpnaasinstall == "yes" ]
then
	sed -r -i "s/VPNAAS_INSTALL_BOOL/True/" /etc/openstack-dashboard/local_settings
else
	sed -r -i "s/VPNAAS_INSTALL_BOOL/False/" /etc/openstack-dashboard/local_settings
fi

if [ $disableconsole == "yes" ]
then
	sed -r -i 's/^\#CONSOLE_TYPE.*/CONSOLE_TYPE\ =\ None/g' /etc/openstack-dashboard/local_settings
fi

sync
sleep 5
sync
echo "" >> /etc/openstack-dashboard/local_settings
echo "SITE_BRANDING = '$brandingname'"  >> /etc/openstack-dashboard/local_settings
echo "" >> /etc/openstack-dashboard/local_settings

#
# We configure here our cache backend - either database or memcache
#

if [ $horizondbusage == "yes" ]
then
        echo "" >> /etc/openstack-dashboard/local_settings
	echo "SESSION_ENGINE = 'django.contrib.sessions.backends.db'" >> /etc/openstack-dashboard/local_settings
        echo "CACHES = {" >> /etc/openstack-dashboard/local_settings
        echo "    'default': {" >> /etc/openstack-dashboard/local_settings
        echo "        'BACKEND': 'django.core.cache.backends.db.DatabaseCache'," >> /etc/openstack-dashboard/local_settings
	echo "        'LOCATION': 'openstack_db_cache'," >> /etc/openstack-dashboard/local_settings
        echo "    }" >> /etc/openstack-dashboard/local_settings
        echo "}" >> /etc/openstack-dashboard/local_settings
        echo "" >> /etc/openstack-dashboard/local_settings
	case $dbflavor in
	"postgres")
		echo "DATABASES = {" >> /etc/openstack-dashboard/local_settings
		echo "               'default': {" >> /etc/openstack-dashboard/local_settings
		echo "               'ENGINE': 'django.db.backends.postgresql_psycopg2'," >> /etc/openstack-dashboard/local_settings
		echo "               'NAME': '$horizondbname'," >> /etc/openstack-dashboard/local_settings
		echo "               'USER': '$horizondbuser'," >> /etc/openstack-dashboard/local_settings
		echo "               'PASSWORD': '$horizondbpass'," >> /etc/openstack-dashboard/local_settings
		echo "               'HOST': '$dbbackendhost'," >> /etc/openstack-dashboard/local_settings
		echo "               'default-character-set': 'utf8'" >> /etc/openstack-dashboard/local_settings
		echo "            }" >> /etc/openstack-dashboard/local_settings
		echo "}" >> /etc/openstack-dashboard/local_settings
		;;
	"mysql")
		echo "DATABASES = {" >> /etc/openstack-dashboard/local_settings
		echo "               'default': {" >> /etc/openstack-dashboard/local_settings
		echo "               'ENGINE': 'django.db.backends.mysql'," >> /etc/openstack-dashboard/local_settings
		echo "               'NAME': '$horizondbname'," >> /etc/openstack-dashboard/local_settings
		echo "               'USER': '$horizondbuser'," >> /etc/openstack-dashboard/local_settings
		echo "               'PASSWORD': '$horizondbpass'," >> /etc/openstack-dashboard/local_settings
		echo "               'HOST': '$dbbackendhost'," >> /etc/openstack-dashboard/local_settings
		echo "               'default-character-set': 'utf8'" >> /etc/openstack-dashboard/local_settings
		echo "            }" >> /etc/openstack-dashboard/local_settings
		echo "}" >> /etc/openstack-dashboard/local_settings
		;;
	esac

	mkdir -p /var/lib/dash/.blackhole
	/usr/share/openstack-dashboard/manage.py syncdb --noinput > /dev/null 2>&1
	/usr/share/openstack-dashboard/manage.py createcachetable openstack_db_cache
	sleep 5
	/usr/share/openstack-dashboard/manage.py inspectdb
	sleep 5
else
	echo "" >> /etc/openstack-dashboard/local_settings
	echo echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" >> /etc/openstack-dashboard/local_settings
	echo "CACHES = {" >> /etc/openstack-dashboard/local_settings
	echo "    'default': {" >> /etc/openstack-dashboard/local_settings
	echo "        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache'," >> /etc/openstack-dashboard/local_settings
	echo "        'LOCATION': '127.0.0.1:11211'," >> /etc/openstack-dashboard/local_settings
	echo "    }" >> /etc/openstack-dashboard/local_settings
	echo "}" >> /etc/openstack-dashboard/local_settings
	echo "" >> /etc/openstack-dashboard/local_settings
fi

echo "Done"

#
# On Centos, we need to apply some new selinux rules for apache
#

echo ""
echo "Applying SELINUX rules for apache. This could take some time. Please wait"

setsebool -P httpd_can_network_connect on

# BUG - FIX
chown -R apache:apache /usr/share/openstack-dashboard/static

echo ""

#
# Done with the configuration, we proceed to apply iptables rules and start/enable services
#

echo "Done"
echo ""
# echo "Applying IPTABLES rules"
# echo ""

# iptables -A INPUT -p tcp -m multiport --dports 80,443,11211 -j ACCEPT
# service iptables save

echo "Ready"
echo ""
echo "Starting Services"

chown -R apache.apache /var/log/horizon

sync
sleep 2
sync

if [ -f /var/www/html/index.html ]
then
	mv /var/www/html/index.html /var/www/html/index.html.original
	cp ./libs/index.html /var/www/html/
else
	cp ./libs/index.html /var/www/html/
fi

#
# Patch - Material Theme is not properlly packaged. Some fonts are missing.
# Those command solve the situation:

yum -y install python2-XStatic-roboto-fontface roboto-fontface-common roboto-fontface-fonts mdi-common mdi-fonts python2-XStatic-mdi
yum -y reinstall python2-XStatic-roboto-fontface roboto-fontface-common roboto-fontface-fonts mdi-common mdi-fonts python2-XStatic-mdi

if [ ! -f /usr/share/openstack-dashboard/static/horizon/lib/roboto_fontface/fonts/Roboto-Regular.woff ]
then
	mkdir -p /usr/share/openstack-dashboard/static/horizon/lib/roboto_fontface/fonts
	mkdir -p /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/font-awesome/fonts
	mkdir -p /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/roboto_fontface/fonts
	cp -v /usr/share/fonts/roboto_fontface/* /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/roboto_fontface/fonts
	cp -v /usr/share/fonts/fontawesome/* /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/font-awesome/fonts
fi

if [ ! -f /usr/share/openstack-dashboard/static/horizon/lib/mdi/fonts/materialdesignicons-webfont.woff ]
then
	mkdir -p /usr/share/openstack-dashboard/static/horizon/lib/mdi/fonts
	mkdir -p /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/mdi/fonts
	cp -v /usr/share/fonts/mdi/* /usr/share/openstack-dashboard/openstack_dashboard/static/horizon/lib/mdi/fonts/
fi

#
# End of patch
#


cat ./libs/memcached/memcached > /etc/sysconfig/memcached
sed -r -i "s/0.0.0.0/$horizonhost/g" /etc/sysconfig/memcached
systemctl enable memcached
systemctl stop memcached
systemctl start memcached
systemctl enable memcached
chkconfig memcached on
systemctl restart httpd
systemctl enable httpd

# Grafana installation is next:

if [ $grafanainstall == "yes" ]
then
	yum -y install initscripts fontconfig
	yum -y install https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.6.3-1.x86_64.rpm
	systemctl stop grafana-server
	systemctl enable grafana-server

	crudini --set /etc/grafana/grafana.ini server http_addr $horizonhost
	crudini --set /etc/grafana/grafana.ini server http_port 3000
	crudini --set /etc/grafana/grafana.ini security admin_user admin
	crudini --set /etc/grafana/grafana.ini security admin_password $grafanapass
	grafana-cli plugins install gnocchixyz-gnocchi-datasource
	grafana-cli plugins install gnocchixyz-gnocchi-datasource

	systemctl restart grafana-server
fi

#
# And finally, we ensure our packages are correctly installed, if not, we fail and stop
# further procedures.
#

testhorizon=`rpm -qi openstack-dashboard|grep -ci "is not installed"`
if [ $testhorizon == "1" ]
then
	echo ""
	echo "Horizon Installation Failed. Aborting !"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/horizon-installed
	date > /etc/openstack-control-script-config/horizon
fi

echo "Done"
echo ""
echo "Horizon Dashboard Installed"
echo ""
