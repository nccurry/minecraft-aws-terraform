# Minecraft AWS Terraform

Terraform plan to deploy a PaperMC Minecraft Server into AWS

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
terraform init
terraform plan
terraform apply
```

## Miscellaenous

### Links

* [PaperMC Image Tags](https://hub.docker.com/r/marctv/minecraft-papermc-server/tags)