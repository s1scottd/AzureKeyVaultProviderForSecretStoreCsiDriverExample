# Test Azure Key Vault Provider

TestAzureKeyVaultProvider is a simple microservice application that uses the Secret Store CSI Driver and the Azure Key Vault Provider.  The use case I needed to solve was: How do I use the Azure Key Vault to store secrets that can be used by non Azure instance of a Kubernetes Cluster.  The challenge was to find documentation on how to do this.  There are many references on how to do this with the Azure Kubernetes Service, but I found nothing on how to do this with a local Kubernetes service.  The key to figuring this out was finding a discussion of the five modes for accessing a Key Vault Instance. (<https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/getting-started/usage/>).  The Service Principal Identity is the only mode available for a non Azure environment.  This creates a security hole because the Service Principal `AppId` and `Password` need to be stored as Kubernetes Secrets which is not secure.  I choose to ignore this for this example, but it is an issue.  There are various ways to encrypt the Kubernetes Secrets, but this was outside of the scope of this project.

## Directory Structure

- `AzureKeyVaultProviderForSecretStoreCsiDriverExample`
  - `TestAzureKeyVaultProvider`: Contains all the source code for the simple microservice.
  - `K8s`: Contains all the scripts and YAML files to deploy the microservice.

## Technologies Used

- ASP.NET Core
- Docker
- Kubernetes
- Azure Key Vault

## Setup

This project was created on Windows 11, but it could easily be ported to MacOS or Linux.  

The development environment:

- Visual Studio Code (v1.80.1).
- NET 7.0.
- Docker Desktop (v4.21.1) with Kubernetes (v1.27.2) enabled.
- The bash shell via the WSL terminal of Visual Studio Code.
- A DockerHub account (`it's free`).

Please ensure that you have the follow installed:

### Helm

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### gettext

```bash
apt-get install gettext-base
```

### Deploy the Azure Key Vault Provider for Secrets Store CSI Driver

```bash
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
helm install csi csi-secrets-store-provider-azure/csi-secrets-store-provider-azure --namespace kube-system
```

*The Helm chart includes the Secrets Store CSI Driver in addition to the Azure Key Vault Provider.*

### Verify that the provider and driver are installed

```bash
kubectl get pods --namespace=kube-system
```

The response will be similar to:

```bash
NAME                                         READY   STATUS    RESTARTS       AGE

csi-csi-secrets-store-provider-azure-kcbvh   1/1     Running   6 (10h ago)    3d9h
secrets-store-csi-driver-csrkd               3/3     Running   18 (10h ago)   3d9h
```

### Clone GitHub Repository

```bash
git clone git@github.com:s1scottd AzureKeyVaultProviderForSecretStoreCsiDriverExample.git
```

### Build Microservice

```bash
cd TestAzureKeyVaultProvider
docker build -t <Your DockerHub User Name>/<test-azure-key-vault-provider>
docker push <Your DockerHub User Name>/<test-azure-key-vault-provider>
```

### Deploy Microservice on Kubernetes

```bash
cd ..\K8s
az login
.\deploy-test-azure-key-vault-provider.sh
```

### Verify that microserve is running in Kubernetes

```bash
kubectl get pods

# The response will be a list of pods.  
# The microservice pod will be listed in the form: 
#
#   test-azure-key-vault-provider-depl-xxxxxxxxx-xxxxx
#

kubeclt logs test-azure-key-vault-provider-depl-xxxxxxxxx-xxxxx

# The respone will be similar to the following:
#
# secret1: This is the first secret
# secret2: This is the second secret
# secret3: This is the third secret
# secret4: This is the fourth secret
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: http://[::]:80
# info: Microsoft.Hosting.Lifetime[0]
#       Application started. Press Ctrl+C to shut down.
# info: Microsoft.Hosting.Lifetime[0]
#       Hosting environment: Production
# info: Microsoft.Hosting.Lifetime[0]
#       Content root path: /app
```

## Future Enhancements

- Encrypt Kubernetes Secrets.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## References

<https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/demos/standard-walkthrough/>

*`Secrets Store CSI Driver: Bringing external secrets in house* YouTube Video
(<https://www.youtube.com/watch?v=KOh43en5dEY&t=6s>)
