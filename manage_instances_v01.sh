#!/bin/bash 
#
# INIT EC2 TOOL Surroundungs
. init_ec2-tools.conf
#
usage="mangage_instances  --start | --stop | --info "
#
#
# config 
# ======
instance_id="i-34XXXX46"



#
# PARAMETERUBERGABE SCHNIPSSEL
# ============================
#
while [ $# -gt 0 ]
do
    arg=$1
    wert=$2
    if [ "$arg" = "--start"  ]; then
        start_contr="yes"
        shift
    elif [ "$arg" = "--stop"  ]; then
        stop_contr="yes"
        shift
    elif [ "$arg" = "--info" ]; then
        info_contr="yes"
        shift
    elif [ "$arg" = "--ssh" ]; then
        ssh_contr="yes"
        shift
    else
        echo "Fehler in der Parameter uebergabe"
        echo $usage
        exit 1
    fi
done


# SCHNIPPSEL
# ==========
# Kreate a new Instance !!!
# ec2-run-instances ami-a59f19cc -k clone1_genlux -t t1.micro
#
# START an "existing" Instance
# ec2-start-instances  $instance_id

# STOP an Instance
# ec2-stop-instances $instance_id




# FUNKTIONEN
# ==========

instance_info() {
    # sed ersetzt die \t durch | und macht platz zwischen den einzelnen Instancen 
    ec2-describe-instances | sed 's/\t/ | /g'  | sed 's/RESERVATION/\n<MARKER> RESERV/g' > info_instances.tmp
}

info_show() {
    instance_info
    awk -F'|' '/INSTANCE/ {print $2 $6 $10 $7 $4 }' info_instances.tmp 
    # 7 KEYNAME 
    # 4 URL 
    # 2 instance_id 
    # 6 status
    # 10 power
}



start_instance() {
#
# schau nach ob der Status der instance auf running gesetzt wurden.
# endlosschleife wird durch break in der if abfrage unterbrochen.
#

#
ec2-start-instances  $instance_id
while true
do
    echo "Booting instance $instance_id  ist in Progress"
    # sed ersetzt die \t durch | und macht platz zwischen den einzelnen Instancen
    # ec2-describe-instances | sed 's/\t/ | /g'  | sed 's/RESERVATION/\n<MARKER> RESERV/g' > info_instances.tmp
    instance_info
    echo "Info about your Instances writen to info_instances.tmp"
    # sucht nach running in der info_instance um, geht nur wenn alle andern aus sind.
    # sollte durch awk ersetzt werden.
    status=$(awk -F"|" '/'$instance_id'/ {print $6}' info_instances.tmp)
    echo $status
    if [ $status = "running" ]; then 
        echo "Instance $instance_id is started now."
        break
    fi
    sleep 30
done
}


stop_instance() {
    # STOPEN
    # ec2-stop-instances i-39XXXX46
    ec2-stop-instances $instance_id 
    echo "The instance $instance_id now shutdown."
    while true
    do 
        instance_info
        echo "Infos about your Instances writen to info_instances.tmp"
        status=$(awk -F'|' '/'$instance_id'/ {print $6}' info_instances.tmp) 
        echo "the status of instance $instance_id is $status"
        if [ $status = "stopped" ]; then
            echo "The instance $instance_id is now $status"
            break
        fi
        sleep 30
    done

}


ssh_instance() {
    instance_info
    keypair=$(awk -F'|' '/'$instance_id'/ {print $7}' info_instances.tmp | sed 's/ *$//g' ) 
    key_dat="${keypair}.pem"
    url=$(awk -F'|' '/'$instance_id'/ {print $4}' info_instances.tmp | sed 's/^ *//g'  )
    username="ec2-user"
    echo "url: $url"
    echo "username: $username"
    echo "key:$keypair"
    echo "$key_dat"
    ssh -i $key_dat  $username@$url
    
}




# MAIN PART
# =========

if [ "$start_contr" = "yes" ]; then
    start_instance

elif [ "$stop_contr" = "yes" ]; then
    stop_instance

elif [ "$info_contr" = "yes" ]; then
    info_show
elif [ "$ssh_contr" = "yes" ]; then
    ssh_instance

else
    echo "kein Paramter gesetzt keine Funktion gefunden"
    echo $usage
fi








