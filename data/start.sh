#!/bin/bash
set -e

config_path=/data/conf/zabbix_agentd.conf
update_config_var() {
    local var_name=$1
    local var_value=$2
    local is_multiple=$3

    # Remove configuration parameter definition in case of unset parameter value
    if [ -z "$var_value" ]; then
        sed -i -e "/$var_name=/d" "$config_path"
        echo "Bootstrap: removed $var_name"
        return
    fi

    # Escaping "/" character in parameter value
    var_value=${var_value//\//\\/}

    if [ "$(grep -E "^$var_name=" $config_path)" ] && [ "$is_multiple" != "true" ]; then
        sed -i -e "/^$var_name=/s/=.*/=$var_value/" "$config_path"
        echo "Bootstrap: updated $var_name to $var_value"
    elif [ "$(grep -Ec "^# $var_name=" $config_path)" -gt 1 ]; then
        sed -i -e  "/^[#;] $var_name=$/i\\$var_name=$var_value" "$config_path"
        echo "Bootstrap: added first occurrence of $var_name to $var_value"
    else
        sed -i -e "/^[#;] $var_name=/s/.*/&\n$var_name=$var_value/" "$config_path"
        echo "Bootstrap: added $var_name=$var_value"
    fi

}

update_config_var "Server" "${ZBX_Server}"

if [ -d "/conf" ]; then
  echo "Bootstrap: found configuration folder, copying contents to /data"
  cp -R /conf /data/conf
fi
chown -R zabbix /data /var/run/docker.sock
echo "Bootstrap: starting agent..."
sudo -u zabbix zabbix_agentd -f -c "$config_path"
