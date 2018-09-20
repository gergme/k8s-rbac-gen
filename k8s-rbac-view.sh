#!/usr/bin/env bash

# Import helper
. ./inc/simple_curses.sh

# Main function
main (){
    window "OptimisCorp Kubernetes RBAC Viewer" "green"
    append "`date`"
    addsep
    append "Context: `kubectl config current-context`" 
    endwin 

    window "Password Authentication Details" "blue"
    K8S_USERS=(`kubectl config view --minify -o=json | jq -r '.users[].user.username'`)
    K8S_AUTH_PW=(`kubectl config view --minify -o=json | jq -r '.users[].user.password'`)
    for a in ${K8S_USERS[@]}; do
	for b in ${K8S_AUTH_PW[@]}; do
	
	[[ "${a}" == "null" ]] && append "No username/password auth detected" || append "${a} ${b}"
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

debug
} 

debug() {
K8S_USERS_size=${#K8S_USERS}
K8S_AUTH_PW_size=${#K8S_AUTH_PW}
K8S_CERT_size=${#K8S_CERT}
K8S_KEY_size=${#K8S_KEY}
printf "K8S_USERS = ${K8S_USERS_size}\n"
printf "K8S_AUTH_PW = ${K8S_AUTH_PW_size}\n"
printf "K8S_CERT = ${K8S_CERT_size}\n"
printf "K8S_KEY = ${K8S_KEY_size}\n"
}

main_loop 0.5


