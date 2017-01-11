#!/bin/bash
docker run --name zabbix-agent \
  --link zabbix:zabbix \
  -p 10050:10050 \
  -v `pwd`/conf:/conf \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -d zabbix-agent
