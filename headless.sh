#!/usr/bin/env bash
# script to set up and run a VirtualBox headless machine automaticly

TEMP_FILE="/Users/$(whoami)/.headless"
OVA_FILE=""
SHARED_FOLDER=""
VM_NAME="BriteCore_VM"


# check if VirtualBox exist
if [ "`command -v VBoxManage`" == "" ]; then
    echo "Cannot find VBoxManager, make sure you have virtualbox installed."
    exit 0
fi

is_running () {
    # to check if the Box is running
    if [ "`VBoxManage showvminfo $VM_NAME | grep State | grep running`" == "" ]; then
        # not running
        return 1
    else
        return 0
    fi
}

# if --stop is passed
if [ "$1" == "--stop" ];then
    if is_running; then
        VBoxManage controlvm "$VM_NAME" poweroff
        echo "VM box stopped ..."
        exit 0
    else
        echo "VM box is not running !"
        exit 1
    fi
fi

is_there () {
    # to chek if the Box already added
    if [ "`VBoxManage list vms | grep $VM_NAME`" == "" ]; then
        return 1
    else
        return 0
    fi
}

not_file () {
    # to print message and exit, if not file
    # param: $1 file
    # param: $2 message
    if [ ! -f $1 ];then
        echo $1
        echo "$2"
        exit 1
    fi
}

not_dir () {
    # to print message and exit, if not dir
    # param: $1 dir
    # param: $2 message
    if [ ! -d "$1" ]; then
        echo "$2"
        exit 1
    fi
}


set_vars () {
    # if the temp file exist, get the stored input
    # if not prompt user
    if [ -f "$TEMP_FILE" ]; then
        # read file and set vars
        read INPUT < $TEMP_FILE
        for got in $(echo $INPUT | tr ";" "\n");do
            if [ "$OVA_FILE" == "" ];then
                OVA_FILE="$got"
            else
                SHARED_FOLDER="$got"
            fi
        done
    else
        read -e -p "Enter your OVA file path >  " OVA_FILE
        not_file "$OVA_FILE" "Error: Invalid .OVA file path entered"
        read -e -p "Enter the source-code folder path >  " SHARED_FOLDER
        not_dir "$SHARED_FOLDER" "Error: Invalid folder path entered"
        echo "$OVA_FILE;$SHARED_FOLDER" > "$TEMP_FILE"
    fi
}

start_vm () {
    # to start headless box and ssh to it
    # $1 equals "true" if first time
    VBoxManage startvm "$VM_NAME" --type headless
    if [ "$1" == "true" ]; then
        if [ ! -f "/Users/$(whoami)/.ssh/id_rsa" ]; then
            ssh-keygen -t rsa
        fi
        # to login without password
        ssh-copy-id vagrant@localhost -p 2222
    fi
    ssh vagrant@localhost -p 2222
}


if is_there ;then
    if is_running ;then
        ssh vagrant@localhost -p 2222
    else
        start_vm
    fi
else
    set_vars
    echo -n "# importing the .ova file to virtualbox ..."
    VBoxManage import "$OVA_FILE" --vsys 0 --vmname "$VM_NAME"
    if is_there ;then
        VBoxManage sharedfolder add "$VM_NAME" --hostpath "$SHARED_FOLDER" --automount
        start_vm "true"
    else
        echo "Error: failed to import the .OVA file"
        exit 1
    fi
fi
exit 0