# docker-monitoring-zabbix-agent
Dockerized Zabbix agent that is able to monitor both docker containers and the host. Full configuration file can be given to the container to run zabbix agent. 

Monitors following docker stats:

* CPU
* Memory
* Disk space used by container
* Incoming and outgoing network traffic
* Container status
* Container uptime
* Container count

Usage:

Copy a configuration file called zabbix_agentd.conf into the conf/ folder. Then run the command:
	docker run --name docker-monitoring-zabbix-agent \
	  -v `pwd`/conf:/conf \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -d docker-monitoring-zabbix-agent

Socket is needed for monitoring containers. You can modify the mounts otherwise how ever you like to suite your monitoring needs.


