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
Copy a configuration file called zabbix_agentd.conf into the conf/ folder. You can also copy any files such as certificates or other files under the conf/ file and reference them with the zabbix_agentd.conf as /data/conf/<filepath>.

An example configuration file can be found here: https://github.com/digiapulssi/docker-monitoring-zabbix-agent/blob/NAKKI-844/conf/zabbix_agentd.conf

```
docker run --name docker-monitoring-zabbix-agent \
-v `pwd`/conf:/conf \
-v /var/run/docker.sock:/var/run/docker.sock \
-d docker-monitoring-zabbix-agent
```

Socket is needed for monitoring containers. As said, you can modify the mount points how ever you like to suite your monitoring needs.

## Using environment parameters:

The container contains internal configuration file which is used if a full configuration is not given inside the conf/zabbix_agentd.conf. The if a configuration file is given, any ZBX_ prefixed environment variables have no effect, since the configuration is overwritten completely.

```
docker run --name docker-monitoring-zabbix-agent \
-e ZBX_Server=<zabbix-address>
-v /var/run/docker.sock:/var/run/docker.sock \
-d docker-monitoring-zabbix-agent
```

Following environment variables are used:
* DEBUG=True
 * Will cause the discovery script to log what it is doing and when.
* ZBX_Server
 * Server host name or ip




