#!/bin/bash
set -e
cp -R /conf /data/conf
chown -R zabbix /data /var/run/docker.sock
sudo -u zabbix zabbix_agentd -f -c /data/conf/zabbix_agentd.conf
