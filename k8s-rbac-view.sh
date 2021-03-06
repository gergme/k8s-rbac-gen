#!/usr/bin/env bash

# Check for required software
check_required(){
	command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }
}

# Import helper
. ./inc/simple_curses.sh

# Main function
main (){
    window "Kubernetes RBAC Viewer" "green"
    append "`date`"
    addsep
    append "Context: `kubectl config current-context`" 
    endwin 

    window "Password Authentication Details" "blue"
    K8S_USERS=(`kubectl config view --minify -o=json | jq -r '.users[].user.username'`)
    K8S_AUTH_PW=(`kubectl config view --minify -o=json | jq -r '.users[].user.password'`)
    for a in ${K8S_USERS[@]}; do
	for b in ${K8S_AUTH_PW[@]}; do
	
	[[ "${a}" == "null" ]] && append "No username/password auth detected" || append "Auth User: ${a}"; append "Auth Passwd: ${b}"
    	done
    done
    endwin
    
    window "Client Certificates" "magenta"
    [[ $(kubectl config current-context) == "minikube" ]] && K8S_CERT=(`kubectl config view --raw --minify -o=json | jq -r '.users[].user | with_entries(select(.key|match("client-certificate")))[]'`) || \
    K8S_CERT=(`kubectl config view --raw --minify -o=json | jq -r '.users[].user | with_entries(select(.key|match("client-certificate-data")))[]'`)
    for c in ${K8S_CERT[@]}; do
	[[ "${#c}" == "0" ]] && append "No client certificate detected" || append "${c}"
    done
    endwin

    window "Client Keys" "yellow"
    [[ $(kubectl config current-context) == "minikube" ]] && K8S_KEY=(`kubectl config view --raw --minify -o=json | jq -r '.users[].user | with_entries(select(.key|match("client-key")))[]'`) || \
    K8S_KEY=(`kubectl config view --raw --minify -o=json | jq -r '.users[].user | with_entries(select(.key|match("client-key-data")))[]'`)
    for d in ${K8S_KEY[@]}; do
	[[ "${#d}" == "0" ]] && append "No client key detected" || append "${d}"
    done
    endwin        

} 

check_required
main_loop 0.5


