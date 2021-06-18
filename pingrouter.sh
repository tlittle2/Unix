#!/bin/bash

while true;
    do
        if eval ping -c 1 8.8.8.8
            then
                echo
        else
                DATE=`date +"%m-%d-%y"`
                TIME=`date +"%T"`
                echo "Network Unreachable on ${DATE} at ${TIME}" >> pinglog.txt
        fi
    sleep 60
    done