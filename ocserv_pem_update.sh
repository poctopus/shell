#!/bin/bash

# Function to determine the Linux distribution
function get_system() {
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        system_str="0"
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        system_str="1"
    else
        echo "This Script must be running at the CentOS or Ubuntu or Debian!"
        exit 1
    fi
}

# Function to stop ocserv service
function stop_service() {
    if [ "$system_str" = "0" ]; then
        service ocserv stop
    else
        systemctl stop ocserv
    fi
}

# Function to start ocserv service
function start_service() {
    if [ "$system_str" = "0" ]; then
        service ocserv restart
    else
        systemctl restart ocserv
    fi
}

# Function to remove old certificates and download new ones
function rm_and_download() {
    cd /etc/ocserv/ || exit 1 # Move to the ocserv directory
    rm -f *.pem

    # Download certificates
    wget https://ikea.alashop.net/pem/ca.cert.pem || {
        echo "Failed to download ca.cert.pem"
        exit 1
    }
    wget https://ikea.alashop.net/pem/server.cert.pem || {
        echo "Failed to download server.cert.pem"
        exit 1
    }
    wget https://ikea.alashop.net/pem/server.pem || {
        echo "Failed to download server.pem"
        exit 1
    }
}

# Function to update certificates
function update_cert() {
    get_system
    stop_service
    rm_and_download
    start_service
}

# Call the function to update certificates
update_cert
