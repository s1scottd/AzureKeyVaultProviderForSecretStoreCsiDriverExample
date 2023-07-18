#!/bin/bash

# This script deploys the test-azure-key-vault-provider application to a Kubernetes cluster
# It assumes that the cluster has been created and that the kubectl context is set to the cluster
# It also assumes that the user has logged in to Azure using the Azure CLI and that the subscription
# has been set to the subscription that the cluster is in
#
# The script takes two parameters:
# 1. The subscription ID
# 2. The tenant ID
#
#  Usage: ./deploy-testapi.sh <subscription-id> <tenant-id>
#

# Set up environment variables
export SUBSCRIPTION_ID=$1
export TENANT_ID=$2

export KEYVAULT_RESOURCE_GROUP=test-azure-key-vault-provider-rg
export KEYVAULT_LOCATION=westus2
export KEYVAULT_NAME=secret-store-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

# Create resource group and keyvault
az group create -n ${KEYVAULT_RESOURCE_GROUP} --location ${KEYVAULT_LOCATION}
az keyvault create -n ${KEYVAULT_NAME} -g ${KEYVAULT_RESOURCE_GROUP} --location ${KEYVAULT_LOCATION}

# Create secrets
az keyvault secret set --vault-name ${KEYVAULT_NAME} --name secret1 --value "This is the first secret"
az keyvault secret set --vault-name ${KEYVAULT_NAME} --name secret2 --value "This is the second secret"
az keyvault secret set --vault-name ${KEYVAULT_NAME} --name secret3 --value "This is the third secret"
az keyvault secret set --vault-name ${KEYVAULT_NAME} --name secret4 --value "This is the fourth secret"

# Create service principal
service_principal=$(python3 create-service-principal.py)
export SERVICE_PRINCIPAL_CLIENT_ID=$(echo "$service_principal" | head -n 1)
export SERVICE_PRINCIPAL_CLIENT_SECRET=$(echo "$service_principal" | tail -n 1)

# Assign permissions to service principal
az keyvault set-policy -n ${KEYVAULT_NAME} --secret-permissions get --spn ${SERVICE_PRINCIPAL_CLIENT_ID}

# Create Kubernets Secret with credentials
kubectl delete secret secrets-store-creds
kubectl create secret generic secrets-store-creds --from-literal clientid=${SERVICE_PRINCIPAL_CLIENT_ID} --from-literal clientsecret=${SERVICE_PRINCIPAL_CLIENT_SECRET}
kubectl label secret secrets-store-creds secrets-store.csi.k8s.io/used=true

# Substitute environment variables in SecretProviderClass file and deploy
envsubst < test-azure-key-vault-provider-spc.yaml | kubectl apply -f -
kubectl apply -f test-azure-key-vault-provider-depl.yaml
