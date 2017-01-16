# docker-monitoring-zabbix-agent
Note: currently in development, so might be some issues that need resolving.

Dockerized Zabbix agent that is able to monitor both docker containers and the host. Full configuration file can be given to the container to run zabbix agent. 

Monitors following docker stats:

* CPU
* Memory
* Disk space used by container
* Incoming and outgoing network traffic
* Container status
* Container uptime
* Container count

It is recommended that containers in the monitored host have a name defined. Otherwise the docker generated name is used and the history data will be lost every time the container is created again.

# Usage:

## General usage:

You can use the docker container to monitor the host by providing it necessary access to the monitored files/logs or systems. You need to enable these via mounting needed paths and make sure they are usable for the docker. Then configure the agent and Zabbix as you would normally. The docker agent monitors host system out of the box (testing needed still).

## Using full configure file and including files for Zabbix agent use:
Copy a configuration file called zabbix_agentd.conf into the /conf folder for the container. If any certificates or other files are to be used, suggestion is to copy also them under the /conf path. Any files in there are moved to /data/conf/<filepath> during startup and the ownership of the files is given to zabbix user. This will avoid the problem where zabbix agent does not have read privileges to files normally mounted with docker.

An example configuration file can be found here: https://github.com/digiapulssi/docker-monitoring-zabbix-agent/blob/NAKKI-844/conf/zabbix_agentd.conf

```
docker run --name docker-monitoring-zabbix-agent \
-p 10050:10050 \
-v /your-config-file:/conf/zabbix-agentd.conf \
-v /var/run/docker.sock:/var/run/docker.sock \
-d digiapulssi/docker-monitoring-zabbix-agent
```

Socket is needed for monitoring containers. As said, you can modify the mount points how ever you like to suite your monitoring needs.

## Using environment parameters:

The container contains internal configuration file which is used if a full configuration is not given inside the conf/zabbix_agentd.conf. You can additionally still define the environment variables to overwrite some configurations, for e.g. the case where there is need to customise the premade configuration easily for different installations.

```
docker run --name docker-monitoring-zabbix-agent \
-p 10050:10050 \
-e ZBX_Server=<zabbix-address>
-v /var/run/docker.sock:/var/run/docker.sock \
-d digiapulssi/docker-monitoring-zabbix-agent
```

Following environment variables are used:
* DEBUG=True
 * Will cause the discovery script to log what it is doing and when.
* ZBX_Server
 * Server host name or ip




