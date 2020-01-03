#!/bin/bash
#ESTABLISHED/LISTEN/SYN_SENT/SYN_RECV/FIN_WAIT1/FIN_WAIT2/TIME_WAIT/CLOSE/CLOSE_WAIT/LAST_ACK/LISTEN/CLOSING/ERROR_STATUS

LISTEN() {
	netstat -an |grep ^tcp |grep LISTEN |wc -l
}

ESTABLISHED() {
	netstat -an |grep ^tcp |grep ESTABLISHED |wc -l
}

TIME_WAIT() {
	netstat -an |grep ^tcp |grep TIME_WAIT |wc -l
}

SYN_SENT() {
	netstat -an |grep ^tcp |grep SYN_SENT |wc -l
}

SYN_RECV() {
	netstat -an |grep ^tcp |grep SYN_RECV |wc -l
}

CLOSE() {
	netstat -an |grep ^tcp |grep CLOSE |wc -l
}

$1
