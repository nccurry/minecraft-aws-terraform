# Minecraft AWS Terraform

Terraform plan to deploy a PaperMC Minecraft Server into AWS

## To-do

- Automatically start / stop server based on activity
- Automated server backups
- Certificate management for plugin pages

## Using this plan

### Download AWS Credentials

```shell
source credentials.env
```

### Create variables file

```shell
touch terraform.tfvars
```

### Execute terraform

```shell
terraform workspace 
terraform init
terraform plan
terraform apply
```

## Miscellaenous

### Links

* [PaperMC Image Tags](https://hub.docker.com/r/marctv/minecraft-papermc-server/tags)
