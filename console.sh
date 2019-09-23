#!/usr/bin/env bash

#define some color
GREEN="\\033[0;32m"
RED="\\033[1;31m"
WHITE="\\033[0;02m"
YELLOW="\\033[1;33m"
CYAN="\\033[1;36m"
NORMAL="\033[0m"
SHORT=$0
SCRIPT_PATH=`dirname $0`

## FUNCTIONS ##
function formatColor(){
    color=$1
    # default
    escapeChar='\e'

    if [ "$(uname)" == "Darwin" ]; then
        # Mac OS X platform
        escapeChar='\x1B'
    # elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    #     # GNU/Linux platform
    # elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    #     # 32 bits Windows NT platform
    # elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    #     # 64 bits Windows NT platform
    fi

    echo "$escapeChar$color"
}

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white=$(formatColor '[1;37m')
    local green=$(formatColor '[1;32m')
    local red=$(formatColor '[1;31m')
    local nc=$(formatColor '[0m')

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

#handle cmd
case "$1" in

docker)

    cd "$SCRIPT_PATH/docker";
    case "$2" in
    start)
        docker-compose -f docker-compose.yml start
    ;;
    stop)
        docker-compose -f docker-compose.yml stop
    ;;
    restart)
        docker-compose -f docker-compose.yml stop
        docker-compose -f docker-compose.yml start
    ;;
    ssh-web)
        docker exec -it deseq-web bash
    ;;
    create)
        docker-compose -f docker-compose.yml down
        docker-compose -f docker-compose.yml build
        docker-compose -f docker-compose.yml up -d --force-recreate
    ;;
    ip)
        docker inspect --format '{{ .NetworkSettings.IPAddress }}' expedicar_web_c
    ;;
     stats)
        docker ps -q | xargs  docker stats --no-stream
     ;;

     redis-ui)
        open http://localhost:8081
     ;;

     esac
    cd -
    exit 0
;;

#Pass info to console
*)
echo -e "$CYAN "
echo -e "$CYAN ############# Console Tools ############# "
echo -e "$CYAN"
echo -e "$NORMAL$SHORT $YELLOW docker (start | stop | restart | create | ssh-web | stats) $NORMAL"
esac