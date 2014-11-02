#!/bin/bash

#Set locale for bc
export LC_NUMERIC="en_US.UTF-8"

IFS=`echo -en "\n\b"`
CUT_AFTER=26
TOTAL_RAM=`cat /proc/meminfo | grep MemTotal | grep -e "[0-9]*" -o`

function testSlash {
    if [ `expr index "$COMMAND" "/"` -eq 1 ]; then
        if [ `expr index "${COMMAND:1}" "/"` -eq 0 ]; then
            echo 3
        elif [ `expr index "${COMMAND:1}" "/"` -lt `expr index "$COMMAND" " "` ]; then
            echo 1
        elif [ `expr index "$COMMAND" " "` -eq 0 ]; then
            echo 1
	elif [ "${COMMAND:0:1}" == "/" ]; then
	    echo 3
        else
            echo 0
        fi
    else
        echo 2
    fi
}

COUNTER=0
for LINE in `/bin/ps -e -o pid,pmem,args --sort -rss | grep -ve "0.[0-5] "`;do #sed '/^ 0.[0-9] /d' | sort -nr
    PID=`echo $LINE | awk '{print $1}'`
    PERCENT=`echo $LINE | awk '{print $2}'`
    COMMAND=`echo $LINE | awk '{ for (i=3; i<=NF; i++) printf("%s ", $i);}'`
    while [ `testSlash` == "1" ]; do
         COMMAND=${COMMAND:1}
         COMMAND=${COMMAND:`expr index "$COMMAND" "/"`-1}
    done
    while [ `testSlash` == "3" ]; do
        COMMAND=${COMMAND:1}
    done

    MEM_MB=`printf "%.1f" $MEM_MB`
    
    if [ "$PID" != "PID" ]; then
      echo "$PID;$PERCENT;`echo $COMMAND | cut -f1 -d' '`"
    let COUNTER=$COUNTER+1
    fi

    SKIP="false"
    
done
#echo processCount=$COUNTER