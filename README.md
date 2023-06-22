## Chemikalien-Gesellschaft Hans Lungmuß mbH & Co. KG

[![Build Image and Release](https://github.com/lungmuss/feuerfest.deploy/actions/workflows/buildandpush.yaml/badge.svg)](https://github.com/lungmuss/feuerfest.deploy/actions/workflows/buildandpush.yaml)

Feuerfest seit 1958.
Ihr Spezialist für innovative feuerfeste Produkte.

Project ID: `FF-167` (Always use this ID, in addition to the GitHub issue ID, in the commit messages)

Please use [Conventional Commits](https://www.conventionalcommits.org) for commit messages.

### GitHub handles contact person

| Handle    | Name        | Role         |
|-----------|-------------|--------------|
| orion6dev | André Jager | Project Lead |

# Introduction

Deploying the Feuerfest Kubernetes cluster can be a daunting task.
In this repository we provide a docker image that contains all the tools needed to deploy the cluster.

# Usage

Start with a clean Ubuntu Linux machine and login:
`ssh root@65.109.138.27 -A`

Clone the Git repo:
`git clone git@github.com:lungmuss/devops.git`

Create a dir for the Sops/Age keys:

`mkdir -p ~/.config/sops/age`

Add your Sops/Age key to keys.txt:

`echo "AGE-SECRET-KEY-1WDKT8LMUM4WESG.........." >> ~/.config/sops/age/keys.txt`

Install Docker:

`apt update && apt install -y apparmor-utils docker.io`

Login on GHCR:

`echo "ghp_7Y2T8fJ8..........." | docker login ghcr.io --username doesnt@matter.com --password-stdin`


Create a iac/Hetzner/secrets.tf from the secrets.tf.example

Download or add your key:

`wget github.com/aikedejongste.keys -O iac/Hetzner/id_rsa.pub`

Start the container:

`docker run -it --rm --name ffdeploy -v "$SSH_AUTH_SOCK:$SSH_AUTH_SOCK" -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -v "/root/.config/sops/age/keys.txt:/root/.config/sops/age/keys.txt" -v "$(pwd)":/opt ghcr.io/lungmuss/feuerfest.deploy:latest`

Create servers with Terraform:

`cd iac/Hetzner && terraform init && terraform apply`

Install the cluster with Ansible:

`cd /opt/ansible && ansible-playbook feuerfest.yaml`
