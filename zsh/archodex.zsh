export AWS_PROFILE=archodex-apurva-AdministratorAccess
export AWS_SDK_LOAD_CONFIG=1
export AWS_REGION=us-west-2

export RESTART_K3D='cd /Users/ajantrania/code/archodex/microservices-demo && k3d cluster stop archodex-dev && k3d cluster start archodex-dev && VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json) && sleep 5 && kubectl exec --namespace vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY && cd --'
