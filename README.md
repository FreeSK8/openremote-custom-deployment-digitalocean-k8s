# Custom Project Deployed with DigitalOcean Kubernetes (DOKS)
This repo is a template for customized, OpenRemote-based projects, which can be deployed
with DigitalOcean k8s resource types using the included terraform configs.

The build pipeline starts with gradle and uses docker images, similar to what is
described here:
https://github.com/openremote/custom-project/blob/main/docker-compose.yml#L13

Volume management happens through DigitialOcean apis via terraform commands, rather
than via docker volumes.  For this reason, the deployment volume (used for 
customization) is deployed as a kubernetes `initContainer` which copies the 
customization folders/files from your custom deployment docker image into the mounted 
persistent volume 'deployment-data'.

You may notice some of the AWS-specific resources from the original examples have no
obvious analogs in the configurations, it's because Kubernetes has internally managed
features which replaced these:
* CloudFormation
* VPC & Security Groups
* Route 53
* SNS

## DevOps Setup

### Create your environment config, and populate it with your project-specific values
```sh
cp .ci_ci/digital_ocean/live/dev/cluster/terragrunt.hcl.example \
   .ci_ci/digital_ocean/live/dev/cluster/terragrunt.hcl
```

To configure & deploy a new environment (i.e. production), copy dev/cluster to 
{envname}/cluster and populate the terragrunt.hcl for that env.

### Install `doctl`, `terragrunt`
OSX:
```sh
brew install doctl
brew install terragrunt
```
Ubuntu:
```sh
sudo snap install doctl
brew install terragrunt
```
Others:
https://docs.digitalocean.com/reference/doctl/how-to/install/
https://terragrunt.gruntwork.io/docs/getting-started/install/

### Install `terraform`
OSX:
```sh
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
```

Others:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

### Setup `pass` for local secrets management:
```sh
brew install pass # OSX
gpg --list-keys # check for plausible personal gpg key to encrypt secrets
# gpg --generate-key # use this if you don't already have one
gpg --list-keys # Copy the long string from the `pub` entry that it lists
pass init XXXXX # paste the string to initialize
```
For installation of pass on other OS's, check https://www.passwordstore.org/#download

### Generate a personal access token for DigitalOcean
Go to the dashboard:
* API > Tokens > Generate new token
* give it a name
* store it securely with `pass insert openremote/do_token`

### Generate a spaces access credentials for DigitalOcean
Go to the daashboard:
* API > Tokens > Spaces Keys
* click "Generate New Key"
* Give it a name, include environment
* store securely with `pass insert openremote/spaces_access_id`, `pass insert openremote/spaces_secret_key`

### Login to DigitalOcean cli tools
```sh
doctl auth init -t $(pass openremote/do_token)
```

## Docker image pipeline

#### DigitalOcean docker registry login
```sh
doctl registry login
```

#### Build & push the proxy image that was adjusted for the DigitalOcean & k8s architecture
Clone the special proxy repo and build it separately from this project:
```sh
pushd ../ && git clone git@github.com:FreeSK8/sk8net_proxy.git && pushd sk8net_proxy
export PROXY_VERSION=$(git rev-parse --short HEAD)
docker build -t openremote/proxy:$PROXY_VERSION .
docker tag openremote/proxy:$PROXY_VERSION registry.digitalocean.com/openremote/openremote/proxy:$PROXY_VERSION
docker push registry.digitalocean.com/openremote/openremote/proxy:$PROXY_VERSION
popd && popd
```

#### Build & push a your project customizations via Deployment docker image
```sh
./gradlew clean installDist
export DEPLOYMENT_VERSION=$(git rev-parse --short HEAD)
docker build -t openremote/custom-deployment:$DEPLOYMENT_VERSION ./deployment/build/
docker tag openremote/custom-deployment:$DEPLOYMENT_VERSION registry.digitalocean.com/openremote/openremote/custom-deployment:$DEPLOYMENT_VERSION
docker push registry.digitalocean.com/openremote/openremote/custom-deployment:$DEPLOYMENT_VERSION
```
**Deploy changes by updating this hash in terragrunt.hcl under `custom_deployment_hash`**

#### Build & push a custom Manager docker image (optional, only if you need it)
You will also need to update the reference in kubernetes_stateful_set.web for the manager image,
point it to your private repo & tag.
```sh
export MANAGER_VERSION="${commit_hash}"
docker build -t openremote/manager:$MANAGER_VERSION ./openremote/manager/build/install/manager/
docker tag openremote/manager:$MANAGER_VERSION registry.digitalocean.com/openremote/openremote/manager:$MANAGER_VERSION
docker push registry.digitalocean.com/openremote/openremote/manager:$MANAGER_VERSION
```

## Deployment

We use [terragrunt](https://blog.gruntwork.io/how-to-manage-multiple-environments-with-terraform-using-terragrunt-2c3e32fc60a8)
to manage k8s deployments using environment based configs. Terraform state is stored in
digital ocean spaces (aka S3) under the bucket openremote-terraform-states.

### Create kubernetes fabric in dev env (once only)
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
export TF_VAR_do_token=$(pass openremote/do_token)
export AWS_ACCESS_KEY_ID=$(pass openremote/spaces_access_id)
export AWS_SECRET_ACCESS_KEY=$(pass openremote/spaces_secret_key)
terragrunt apply -target=digitalocean_kubernetes_cluster.primary 

doctl kubernetes cluster kubeconfig save shared-dev

# Create a k8s secret with CA cert/key.
# This will be used to restrict MQTT client connections at the proxy layer.
# Generate CA and client certs by following the guide:
# https://github.com/openremote/openremote/wiki/User-Guide%3A-Auto-Provisioning#certificate-generation
kubectl -n frontend create secret tls tls-openremote --cert=ca-cert.pem --key=ca-key.pem

```
*human do this: Go into the digital ocean dashboard*
* click container registry
* click settings tab and enable integration for the newly created k8s cluster*

### Deploy or modify terroform-managed volumes, statefulSets, services, proxies:
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
export TF_VAR_do_token=$(pass openremote/do_token)
export AWS_ACCESS_KEY_ID=$(pass openremote/spaces_access_id)
export AWS_SECRET_ACCESS_KEY=$(pass openremote/spaces_secret_key)
terragrunt apply
```
If a new loadbalancer was created (first time you deploy this env), you need to point a
DNS record at it now. You can find the IP of the LB in the DigitalOcean dashboard.

#### Helpful things...

### If a cluster is nuked and volumes are left orphaned, you can import them:
```sh
terragrunt import digitalocean_volume.deployment_data #(id available on inspection of the html table in DO volumes manager, lol)
terragrunt import digitalocean_volume.manager_data #(id)
terragrunt import digitalocean_volume.postgresql_data #(id)
terragrunt import digitalocean_volume.proxy_data #(id)
```

### Remove state for already-deprovisioned resources, or if you want to detach existing resource from tf management
```sh
terragrunt state list

terragrunt state rm kubernetes_persistent_volume_claim.proxy_data # THIS IS AN EXAMPLE, target your desired resource
```

