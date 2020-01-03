#!/bin/bash
#php status by tianyun 2015/12/16 v1.0

idle(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "idle processes:" |awk -F: '{print $2}'
}

total(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "total processes:" |awk -F: '{print $2}'
}

active(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "active processes:" |awk -F: '{print $2}'
}

mactive(){

        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "max active processes:" |awk -F: '{print $2}'
}

listenqueuelen(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "listen queue len:" |awk -F: '{print $2}'
}

listenqueue(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "listen queue:" |awk -F: '{print $2}'
}

since(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "start since: " |awk -F: '{print $2}'
}

conn(){
        wget --quiet -O - http://127.0.0.1/php-fpm_status?auto |grep "accepted conn:" |awk -F: '{print $2}'
}
$1

