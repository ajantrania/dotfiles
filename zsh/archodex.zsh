echo "Loading archodex credentials..."

export AWS_PROFILE=archodex-apurva-AdministratorAccess
export AWS_SDK_LOAD_CONFIG=1
export AWS_REGION=us-west-2

alias UNSEAL_VAULT_MICROSERVICES_DEMO='VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" /Users/ajantrania/code/archodex/microservices-demo/cluster-keys.json) && echo "waiting 20 seconds..." && sleep 20 && kubectl exec --namespace vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY'
alias RESTART_K3D='cd /Users/ajantrania/code/archodex/microservices-demo && k3d cluster stop archodex-dev && sleep 5 && k3d cluster start archodex-dev && UNSEAL_VAULT_MICROSERVICES_DEMO && cd --'
