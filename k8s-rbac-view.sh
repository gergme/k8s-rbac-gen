#!/usr/bin/env bash

# Import helper
. ./inc/simple_curses.sh

# Main function
main (){
    #basic informations, hostname, date,...
    window "OptimisCorp Kubernetes RBAC Viewer" "green"
    append "`date`"
    addsep
    append "Context: `kubectl config current-context` | Namespace: `kubectl config get-contexts | grep -v "CURRENT" | awk '{print $5}' | sed '/^$/d'`" 
    endwin 

    window "Password Authentication Details" "blue"
    K8S_USERS=(`kubectl config view --minify -o=json | jq '.users[].user.username'`)
    K8S_AUTH_PW=(`kubectl config view --minify -o=json | jq '.users[].user.password'`)
    for a in ${K8S_USERS[@]}; do
	for b in ${K8S_AUTH_PW[@]}; do
	
	[[ -s "${a}" ]] && append "No username/password auth detected" || append "${a} ${b}"
    	done
    done
    endwin
    
    window "Client Certificates" "magenta"
    K8S_CERT=(`kubectl config view --raw --minify -o=json | jq '.users[].user | with_entries(select(.key|match("client-certificate-data")))[]'`)
    for c in ${K8S_CERT[@]}; do
	[[ -s "${c}" ]] && append "No client certificate detected" || append "${c}"
    done
    endwin

    window "Client Keys" "yellow"
    K8S_KEY=(`kubectl config view --raw --minify -o=json | jq '.users[].user | with_entries(select(.key|match("client-key-data")))[]'`)
    for d in ${K8S_KEY[@]}; do
	[[ -s "${d}" ]] && append "No client key detected" || append "${d}"
    done
    endwin        

    #memory usage
#    window "Memory usage" "red"
#    append_tabbed `cat /proc/meminfo | awk '/MemTotal/ {print "Total:" $2/1024}'` 2
#    append_tabbed `cat /proc/meminfo | awk '/MemFree/ {print "Free:" $2/1024}'` 2
#    endwin

    #5 more used process ordered by cpu and memory usage
#    window "Processus taking memory and CPU" "green"
#    for i in `seq 2 6`; do
#        append_tabbed "`ps ax -o pid,rss,pcpu,ucmd --sort=-cpu,-rss | sed -n "$i,$i p" | awk '{printf "%s: %smo:  %s%%" , $4, $2/1024, $3 }'`" 3
#    done
#    endwin

    #get dmesg, log it then send to deskbar
#    window "Last kernel messages" "blue"
#    dmesg | tail -n 10 > /dev/shm/deskbar.dmesg
#    append_file /dev/shm/deskbar.dmesg
#    rm -f /dev/shm/deskbar.dmesg
#    endwin

    #a special manipulation to get net interfaces  and IP
#    window "Inet interfaces" "grey"
#    _ifaces=$(for inet in `ifconfig | cut -f1 -d " " | sed -n "/./ p"`; do ifconfig $inet | awk 'BEGIN{printf "%s", "'"$inet"'"} /adr:/ {printf ":%s\n", $2}'|sed 's/adr://'; done)
#    for ifac in $_ifaces; do
#        append_tabbed  "$ifac" 2
#    done
#    endwin
}

main_loop 0.5
