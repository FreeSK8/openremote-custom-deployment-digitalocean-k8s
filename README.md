# Custom Project
This repo is a template for custom projects; showing the recommended project structure and including `README` files in the `deployment` directory to provide details about how to customise each part.

## Setup Tasks
The following `OR_SETUP_TYPE` value(s) are supported:

* `production` - Requires `CUSTOM_USER_PASSWORD` environment variable to be specified 

Any other value will result in default setup.

### (one time only, completed) create Sk8net docker image registry at digitalocean
```sh
doctl registry create sk8net
```

## Encrypted files
If any encrypted files are added to the project then you will need to specify the `GFE_PASSWORD` environment variable to be able to build the project and decrypt the
files.

## DevOps Setup

#### Install `doctl`, `terragrunt`
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

#### Install `terraform`
OSX:
```sh
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
```

Others:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

#### DigitalOcean docker registry login
```sh
doctl registry login
```

#### Tag a deployment and push to DO docker repo
```sh
docker tag openremote/custom-deployment:{target version hash} registry.digitalocean.com/sk8net/openremote/custom-deployment
docker push registry.digitalocean.com/sk8net/openremote/custom-deployment
```

## Deployment

We use [terragrunt](https://blog.gruntwork.io/how-to-manage-multiple-environments-with-terraform-using-terragrunt-2c3e32fc60a8) to manage k8s deployments using environment based configs.

#### Create/update kubernetes fabric in staging env
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
terragrunt apply -target=digitalocean_kubernetes_cluster.primary
```

Set control plane config locally, run this once for your env/cluster:
```sh
doctl kubernetes cluster kubeconfig save shared-dev
```
~Use this command to switch k8s config between clusters when working with different environments

Now create ingress namespace:
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
terragrunt apply -target=kubernetes_namespace.ingress
```

And install the helm chart for our target ingress of nginx
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
NGINX_CHART_VERSION="4.6.1"
helm install ingress-nginx ingress-nginx/ingress-nginx --version "$NGINX_CHART_VERSION" \
  --namespace ingress \
  -f "nginx-values-v${NGINX_CHART_VERSION}.yaml" --set controller.publishService.enabled=true

# once installed you can update settings live:
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --version "$NGINX_CHART_VERSION" \
  --namespace ingress \
  -f "nginx-values-v${NGINX_CHART_VERSION}.yaml" --set controller.publishService.enabled=true
```
^ you can verify this worked, visit k8s dashboard under Service > Ingress Classes

Set up a self-signed certificate and add to digital ocean:
```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.out -out cert.out -subj "/CN=stage.ride.sk8net.org/O=stage.ride.sk8net.org" -addext "subjectAltName = DNS:146.190.198.74"
kubectl create secret tls dev-selfsigned --key key.out --cert cert.out
```

#### Apply terraform configs:
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
terragrunt apply
```




#### Remove state for already-deprovisioned resources, or if you want to detach existing resource from tf management
```sh
terragrunt state list

terragrunt state rm kubernetes_persistent_volume_claim.proxy_data # THIS IS AN EXAMPLE, target your desired resource
```

