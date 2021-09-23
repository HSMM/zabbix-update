#!/bin/bash
yum remove zabbix-agent zabbix-release -y
yum install https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.15-1.el7.x86_64.rpm -y
echo -n > /etc/zabbix/zabbix_agentd.conf
 
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=10.16.0.100
ServerActive=10.16.0.100
Hostname=Zabbix server
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOT
 
rm -rf /usr/src/zabbix-templates
cd /usr/src/
git clone https://github.com/HSMM/zabbix-templates
cd /usr/src/zabbix-templates/asterisk/
rm -rf /etc/zabbix/zabbix_agentd.d/*
mkdir -p /etc/zabbix/zabbix_agentd.d/scripts/
cp zabbix_agentd.d/scripts/asterisk.sh /etc/zabbix/zabbix_agentd.d/scripts/asterisk.sh
chmod 755 /etc/zabbix/zabbix_agentd.d/scripts/asterisk.sh
cp zabbix_agentd.d/asterisk.conf /etc/zabbix/zabbix_agentd.d/asterisk.conf
 
cat <<EOT >> /etc/sudoers
User_Alias ZABBIX = zabbix
Cmnd_Alias ZABBIX_COMMANDS = /usr/sbin/asterisk
Defaults:ZABBIX !requiretty
ZABBIX ALL=(ALL) NOPASSWD: ZABBIX_COMMANDS
EOT
 
systemctl start zabbix-agent
systemctl enable zabbix-agent
systemctl restart zabbix-agent

rm -rf zbx-update.sh
