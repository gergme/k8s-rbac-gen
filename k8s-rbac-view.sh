#!/usr/bin/env bash

# Import helper
. ./inc/simple_curses.sh

# Main function
main (){
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

main_loop 0.5
