#!/bin/bash

LOCAL=`dirname $0`;
cd $LOCAL
cd ../

PWD=`pwd`

LOG_FILE="${PWD}/../logs/active-responses.log"

read INPUT_JSON
echo $INPUT_JSON > "temp.json"

UNKNOWN_PORT=$(grep -o '"local_port":[^,]*' "temp.json" | awk -F ':' '{print $2}' | tr -d '" '|head -n 1)
PROCESS=$(grep -o '"process":[^,]*' "temp.json" | awk -F ':' '{print $2}' | tr -d '" '|head -n 1)

if [ ${PROCESS} = "firefox" ]
then
	exit 0
fi

kill $(lsof -t -i:$UNKNOWN_PORT)

if [ $? -eq 0 ]; then
 echo "`date '+%Y/%m/%d %H:%M:%S'` $0: $INPUT_JSON Successfully closing port $UNKNOWN_PORT" >> ${LOG_FILE}
else
 echo "`date '+%Y/%m/%d %H:%M:%S'` $0: $INPUT_JSON Error closing port $UNKNOWN_PORT" >> ${LOG_FILE}
fi

echo " " >> ${LOG_FILE}

exit 0;