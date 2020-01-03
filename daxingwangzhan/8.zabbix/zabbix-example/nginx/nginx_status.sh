#!/bin/bash
#nginx status

Active(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==1 {print$3}'
}
Accept(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==3 {print$1}'
}
Handled(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==3 {print$2}'
}
Request(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==3 {print$3}'
}
Reading(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==4 {print$2}'
}
Writing(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==4 {print$4}'
}
Waiting(){
        wget --quiet -O - http://localhost/nginx_status?auto |awk 'NR==4 {print$6}'
}
$1

