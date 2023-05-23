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

#### Create/update kubernetes fabric, load balancer for dev
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
terragrunt apply
```

The first time you run the above, it will create a new k8s cluster. You will see errors for the other k8s resources because the control
plane config is not yet set locally. To set it, run this once for your env/cluster, and then run the apply command again:
```sh
doctl kubernetes cluster kubeconfig save shared-dev
```
~Use this command to switch k8s config between clusters when working with different environments

#### Add the load balancer (dev) (not managed by terraform)
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
kubectl apply -f load_balancer.yml
```

#### Remove state for already-deprovisioned resources, or if you want to detach existing resource from tf management
```sh
terragrunt state list

terragrunt state rm kubernetes_persistent_volume_claim.proxy_data # THIS IS AN EXAMPLE, target your desired resource
```
