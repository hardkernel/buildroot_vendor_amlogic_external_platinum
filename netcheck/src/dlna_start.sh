#!/bin/sh

PROCESS=MediaRendererTest

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
    local tempgeteway=0
    while true
    do
        geteway=`route -n |awk '{print $2}' |awk 'NR==3'`
        if [ "${geteway}"x != ""x ] && [ "${geteway}"x != "0.0.0.0"x ];then
            if [ $geteway != $tempgeteway ];then
                if [ $tempgeteway == "0" ];then
                    netcheck $geteway
                    netcheck_res=$?
                    if [ $netcheck_res -eq 1 ]; then
                        echo "dlna start[$geteway]:dlna first start..."
                        $PROCESS &
                        tempgeteway=$geteway
                        flag=1
                    else
                        echo "dlna start[$geteway]:dlna first start err!"
                    fi
                else
                    kill_task $PROCESS
                    netcheck $geteway
                    netcheck_res=$?
                    if [ $netcheck_res -eq 1 ]; then
                        echo "dlna restart[$geteway]:network ip change..."
                        $PROCESS &
                        tempgeteway=$geteway
                        flag=1
                    else
                        echo "dlna restart[$geteway]:err!"
                    fi
                fi
            else
                netcheck $geteway
                netcheck_res=$?
                if [ $netcheck_res -ne $flag ]; then
                    flag=$netcheck_res
                    if [ $flag -eq 1 ]; then
                        echo "dlna start[$geteway]:network connected..."
                        $PROCESS &
                    else
                        echo "dlna stop[$geteway]:network disconnected..."
                        kill_task $PROCESS
                    fi
                fi
            fi
        else
          if [ $flag -eq 1 ];then
            echo "dlna stop:network disconnected..."
            kill_task $PROCESS
            flag=0
          fi
        fi
    done
}

kill_all()
{
    kill_task $PROCESS
    exit
}

trap kill_all INT

dlna_updown

exit
