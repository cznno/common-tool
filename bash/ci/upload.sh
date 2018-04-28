#!/bin/bash

# command=$1

. ./config.sh
################################
##    variable requires       ##
################################
## webapp_path=$webapp_path   ##
## webapp_port=$webapp_port   ##
## serv_path=$serv_path       ##
## serv_name=$serv_name       ##
## web_path=$web_path         ##
## screen_path=$screen_path   ##
## exclude_file=$exclude_file ##
## log_path=$log_path         ##
################################ 
set -euo pipefail

function output_log()
{
    log_temp="[`date`] $1 uploaded"
    echo ${log_temp} >> ${log_path}
}

function upload_serv()
{
    cd ${serv_path}
    svn up
    # mvn clean package | grep '\[INFO\] Finished at' | sed 's/^\[INFO\] Finished at: //g'
    mvn_build=$(mvn clean package | grep '\[INFO\] BUILD' | sed 's/^\[INFO\] //g')
    if [[ ${mvn_build} != '' ]];then
        echo ${mvn_build}
        echo 'uploading war'
        scp -P${webapp_port} ${serv_path}/target/${serv_name}.war ${webapp_path}
    fi
    echo 
    output_log 'serv'    
}

function upload_web()
{
    cd ${web_path}
    svn up
    echo 'uploading web'
    rsync -rvz -e 'ssh -p '${webapp_port} --progress ${web_path} ${webapp_path} --exclude-from=${exclude_file}
}

function upload_screen()
{
    cd ${screen_path}
    svn up
    echo 'uploading screen'
    rsync -rvz -e 'ssh -p '"${webapp_port}"'' --progress ${screen_path}/new/ ${webapp_path}/screen2 --exclude-from=${exclude_file}
    echo
    output_log 'screen'
}

function error()
{
    echo 'please input an operation argument'
}

# function exec_command(){
#     $1
#     if [ $? -eq 0 ]; then
#         echo OK
#     else
#         echo FAIL
#     fi
# }


for command in "$@"
do
    case ${command} in
    'serv') upload_serv;;
    'web') upload_web;;
    'screen') upload_screen;;
    'all') upload_serv;upload_web;upload_screen;;
    *) error
esac
done

echo 'SUCCESS'