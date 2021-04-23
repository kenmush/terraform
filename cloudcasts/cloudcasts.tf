terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.37.0"
    }
  }
  backend "s3" {
    bucket = "terraform-mutisya"
    key = "cloudcasts/terraform.tfstaste"
    profile = "cloudcasts"
    region = "us-east-1"
    dynamodb_table = "cloudcasts"
  }

}

variable "infra_env" {
  type = string
  description = "infrastructure enviroment"
  default = "staging"
}
variable "default_region" {
  type = string
  description = "the region the infrastructure region"
  default = "us-east-1"
}
variable "instance_size" {
  type = string
  default = "t3.small"
}
provider "aws" {
  profile = "cloudcasts"
  region = var.default_region
}

//data "aws_ami" "app" { # Search for ubuntu
//  owners = [
//    "099720109477"]
//  filter {
//    name = "name"
//    values = [
//      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
//  }
//  filter {
//    name = "virtualization-type"
//    values = [
//      "hvm"]
//  }
//  filter {
//    name = "architecture"
//    values = [
//      "x86_64"]
//  }
//  most_recent = true
//}
data "aws_ami" "app" {
  owners = [
    "self"]
  filter {
    name = "state"
    values = [
      "available"]
  }

  filter {
    name = "tag:Project"
    values = [
      "cloudcast"]
  }

  filter {
    name = "tag:Enviroment"
    values = [
      var.infra_env]
  }
  most_recent = true
}

module "ec2_app" {
  source = "./modules/ec2"
  infra_env = var.infra_env
  infra_role = "web"
  instance_size = var.instance_size
  instance_ami = data.aws_ami.app.id
  tags = {
    "Name" = "cloudcasts.${var.infra_env}-app"
  }
  //  instance_root_device_size = "12"
  security_groups = [module.vpc.security_group_public]
  subnets = keys(module.vpc.vpc_public_subnets)
  create_eip = true
}

module "ec2_worker" {
  source = "./modules/ec2"
  infra_env = var.infra_env
  infra_role = "worker"
  instance_size = var.instance_size
  instance_ami = data.aws_ami.app.id
  //  instance_root_device_size = "12"
  security_groups = [module.vpc.security_group_private]
  tags = {
    "Name" = "cloudcasts.${var.infra_env}-worker"
  }
  subnets = keys(module.vpc.vpc_private_subnets)
create_eip = false
}

module "vpc" {
  source = "./modules/vpc"
  infra_env = var.infra_env
  //  vpc_cidr = "10.0.0.0/17"
  vpc_cidr = "10.0.0.0/16"
}