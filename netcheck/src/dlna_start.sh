#!/bin/sh

address=8.8.8.8

taskkill()
{
    if [ $# -ne 2 ]; then
        PID=`ps ax | grep $1 | awk '{if ($0 !~/grep/) {print $1}}'`
        if [ -n "$PID" ]; then
        kill -9 $PID >/dev/null 2>&1
            return 0
        else
            return 1
        fi
    fi
    return 1
}

kill_task()
{
    while true
    do
        taskkill $1
        ret=$?
        if [ $ret -eq 1 ]; then
            break
        fi
    done
}

dlna_updown()
{
    local flag=0
    while true
    do
    netcheck $address
    mping_res=$?
    if [ $mping_res -ne $flag ]; then
        flag=$mping_res
        if [ $flag -eq 1 ]; then
            echo "start dlna..."
            MediaRendererTest &
            else
            echo "stop dlna..."
            kill_task MediaRendererTest
        fi
    fi
    done
}

kill_all()
{
    kill_task MediaRendererTest
    exit
}

trap kill_all INT

dlna_updown

exit
