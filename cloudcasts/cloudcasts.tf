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

resource "aws_instance" "cloudcasts_web" {
  ami = data.aws_ami.app.id
  instance_type = var.instance_size
  root_block_device {
    volume_size = 8
    #GB
    volume_type = "gp3"
  }
  tags = {
    Name = "cloudcasts.${var.infra_env}.io"
    Project = "cloudcasts.io"
    Enviroment = var.infra_env
    ManagedBy = "terraform"
  }
}
resource "aws_eip" "app_eip" {
  vpc = true
  lifecycle {
    #might bite you in the ass sometimes
    prevent_destroy = true
  }
  tags = {
    Name = "cloudcasts-${var.infra_env}-web-address"
    Project = "cloudcasts.io"
    Enviroment = var.infra_env
    ManagedBy = "terraform"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id = aws_instance.cloudcasts_web.id

  allocation_id = aws_eip.app_eip.id

}