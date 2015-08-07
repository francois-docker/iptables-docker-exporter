#! /bin/bash
function export_iptables() {
    file="/tmp/iptables_docker.rules"
    echo "" > $file
    for table in nat filter
    do
        container_ips=`echo $DOCKER_IP_RANGE | cut -d "." -f 1-2`
        iptables_save=`which iptables-save`

        echo "*$table" >> $file
        $iptables_save -t $table | grep $container_ips | grep -v $DOCKER_IP_RANGE >> $file
        echo COMMIT >> $file
    done
}

function is_valid_network() {
    local netmask=$1
    local stat

    if [[ $netmask =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$ ]]; then
        stat=0
    else
        stat=1
        echo "The provided network $netmask is not a valid CIDR - ie: 172.17.0.0/16"
        exit 1
    fi
    return $stat
}

function main {
    if [ -z $DOCKER_IP_RANGE  ]; then
        DOCKER_IP_RANGE=172.17.0.0/16
    fi
    echo $DOCKER_IP_RANGE

    is_valid_network $DOCKER_IP_RANGE

    export_iptables

}

main

