# Custom Project
This repo is a template for custom projects; showing the recommended project structure and including `README` files in the `deployment` directory to provide details about how to customise each part.

## Setup Tasks
The following `OR_SETUP_TYPE` value(s) are supported:

* `production` - Requires `CUSTOM_USER_PASSWORD` environment variable to be specified 

Any other value will result in default setup.

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

#### Setup `pass` for local secrets management:
```sh
brew install pass # OSX
gpg --list-keys # check for plausible personal gpg key to encrypt secrets
# gpg --generate-key # use this if you don't already have one
gpg --list-keys # Copy the long string from the `pub` entry that it lists
pass init XXXXX # paste the string to initialize
```
For installation of pass on other OS's, check https://www.passwordstore.org/#download

#### Generate a personal access token for DigitalOcean
Go to the dashboard:
* API > Tokens > Generate new token
* give it a name
* store it securely with `pass insert sk8net/do_token`

#### Generate a spaces access credentials for DigitalOcean
Go to the daashboard:
* API > Tokens > Spaces Keys
* click "Generate New Key"
* Give it a name, include environment
* store securely with `pass insert sk8net/spaces_access_id`, `pass insert sk8net/spaces_secret_key`

#### Login to DigitalOcean cli tools
```sh
doctl auth init -t $(pass sk8net/do_token)
```

## Docker image pipeline

##### (one time only, completed) create Sk8net docker image registry at digitalocean
```sh
doctl registry create sk8net
```

##### DigitalOcean docker registry login
```sh
doctl registry login
```

##### Build a docker image
```sh
docker build -t openremote/manager:$MANAGER_VERSION ./openremote/manager/build/install/manager/
```

#### Tag a deployment and push to DO docker repo
```sh
docker tag openremote/manager:{target version hash} registry.digitalocean.com/sk8net/openremote/manager
docker push registry.digitalocean.com/sk8net/openremote/manager
```

## Deployment

We use [terragrunt](https://blog.gruntwork.io/how-to-manage-multiple-environments-with-terraform-using-terragrunt-2c3e32fc60a8) to manage k8s deployments using environment based configs. Terraform state is stored in digital ocean spaces (aka S3) under the bucket sk8net-terraform-states.

#### Create/update kubernetes fabric in staging env
```sh
cd .ci_cd/digital_ocean/live/dev/cluster
export TF_VAR_do_token=$(pass sk8net/do_token)
export AWS_ACCESS_KEY_ID=$(pass sk8net/spaces_access_id)
export AWS_SECRET_ACCESS_KEY=$(pass sk8net/spaces_secret_key)
terragrunt apply -target=digitalocean_kubernetes_cluster.primary 

doctl kubernetes cluster kubeconfig save shared-dev

# human do this: Go into the digital ocean dashboard, container registry, click edit and enable integration for the newly created k8s cluster

terragrunt apply

# if a new loadbalancer was created (first time you deploy this env), you need to point a DNS record at it now
```

#### If a cluster is nuked and volumes are left orphaned, you can import them:
```sh
terragrunt import digitalocean_volume.deployment_data #(id available on inspection of the html table in DO volumes manager, lol)
terragrunt import digitalocean_volume.manager_data #(id)
terragrunt import digitalocean_volume.postgresql_data #(id)
```

#### Remove state for already-deprovisioned resources, or if you want to detach existing resource from tf management
```sh
terragrunt state list

terragrunt state rm kubernetes_persistent_volume_claim.proxy_data # THIS IS AN EXAMPLE, target your desired resource
```

