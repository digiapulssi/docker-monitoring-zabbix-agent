# docker-monitoring-zabbix-agent

Dockerized Zabbix agent that is able to monitor docker containers. Uses low level discovery to find docker containers and creates items for them in Zabbix. A full configuration file can be given to the container to run zabbix agent and fully customize the functionality. Not running containers and their items are automatically deleted after defined period (7 days in default template).

* Note: currently in development, so might be some issues that need resolving. The monitoring is implemented via Userparameter that runs a Python script. This causes some cpu load itself. It should not be a problem when the environment monitored does not contain lot of docker containers, but may become issue with systems that have low resources and many containers to monitor. This issue will probably be addressed at some later point.

![Latest data](https://raw.githubusercontent.com/digiapulssi/docker-monitoring-zabbix-agent/master/images/latest-data.png)

Monitors following docker stats for each container:

* CPU
* Memory
* Disk space used by container
* Incoming and outgoing network traffic
* Container status
* Container uptime
* Container count (in host level)

![Discovered items](https://raw.githubusercontent.com/digiapulssi/docker-monitoring-zabbix-agent/master/images/discovered-items.png)
![Container CPU usage](https://raw.githubusercontent.com/digiapulssi/docker-monitoring-zabbix-agent/master/images/cpu-usage.png)

It is recommended that containers in the monitored host have a name defined. Otherwise the docker generated name is used and the history data will be lost every time the container is created again.

# Host monitoring notes: 

Currently the dockerized agent offers only limited host monitoring. Following stats are not available or have some limits:
- Network traffic (container is isolated from seeing network interfaces of the host)
- Filesystems (some mountpoints can be seen inside the container, but not all are discoverable)
- Processes statistics (e.g. number of running processes in host)

System statistics which can be monitored via monitoring some linux system file can be mounted to the docker container, but they may need a customized Zabbix item to point into non-standard path inside the docker container. At later point, host monitoring may be improved in this docker container, but it might need customizing the Zabbix agent code.


# Usage:
## General usage:

You can use the docker container to monitor the host by providing it necessary access to the monitored files/logs or systems. You need to enable these via mounting needed paths and make sure they are usable for the docker. Then configure the agent and Zabbix as you would normally. The docker agent is able to monitor some stats from the host, limited by what is available to the docker container (testing needed still). You may implement your own monitoring of host resources via volume mounts. Since the /proc cannot be mounted into a container directly, some of the stats that the agent sees are actually container local and not from the host.

For discovering containers automatically, the discovery configuration needs to be set up in Zabbix. Download the Zabbix template with the discovery and prototype items here: ![Zabbix Template](https://raw.githubusercontent.com/digiapulssi/docker-monitoring-zabbix-agent/master/zabbix_docker_discovery_template.xml). Link the discovery template to any docker-monitoring-zabbix-agent hosts that are connected to Zabbix. 

## Using full configure file and including files for Zabbix agent use:
Copy a configuration file called zabbix_agentd.conf into the /conf folder for the container. If any certificates or other files are to be used, suggestion is to copy also them under the /conf path. Any files in there are moved to /data/conf/<filepath> during startup and the ownership of the files is given to zabbix user. This will avoid the problem where zabbix agent does not have read privileges to files normally mounted with docker.

An example configuration file can be found here: ![zabbix_agentd.conf](https://raw.githubusercontent.com/digiapulssi/docker-monitoring-zabbix-agent/master/conf/zabbix_agentd.conf)

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
-e ZBX_Server=<zabbix-address> \
-v /var/run/docker.sock:/var/run/docker.sock \
-d digiapulssi/docker-monitoring-zabbix-agent
```

Following environment variables are used:
* DEBUG=True
 * Will cause the discovery script to log what it is doing and when.
* ZBX_Server
 * Server host name or ip


# Stats explained
## Memory
Memory is measured from under cgroup/memory.usage_in_bytes. Description from www.kernel.org:
```For efficiency, as other kernel components, memory cgroup uses some optimization
to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
method and doesn't show 'exact' value of memory (and swap) usage, it's a fuzz
value for efficient access. (Of course, when necessary, it's synchronized.)
If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
value in memory.stat````

## Incoming/outgoing traffic:
Traffic is calculated using the values from rx_byres and tx_bytes under the /sys/devices/virtual/net/eth0/statistics/. The underlying script stores the previous measurement of the values in these files, and also the time when the measurement was taken. It then calculates the traffic between these two measurements. Spikes are not monitored, but the average bandwidth between the two measurement points. 

## Disk usage:
The disk usage is taken with the command. It is approximately valid estimate on how much disk space your container takes.
```docker inspect -s -f .SizeRootFS <container_name>```

## CPU usage:
In similar way to data traffic calculcation, the script uses the file /sys/fs/cgroup/cpuacct/cpuacct.usage to take measurements of how much CPU time the container has used. The file contains time in nanoseconds, as consumed by all tasks under the current cgroup. With the two measurements and real time elapsed between them, we can calculate the CPU utilization percentage. Note that this value is the CPU allocated to the container by the host, and thus "100%" is only for the container in question.

## Status: 
A simple integer stat for reporting what the container status is. Following encoding is used:
```
0 = no container found, 
1 = running, 
2 = shut down, 
3 = abnormal
```
Abnormal basically means that the exit status was other than 0 (meaning error has occured) or there was some other problem.

## Uptime:
Gives the container uptime in seconds. Affected by container restarts.

## Container count:
A host level stat, that simply counts the active containers. 



