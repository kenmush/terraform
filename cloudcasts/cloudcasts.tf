terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
  }
}

provider "aws" {
  profile = "cloudcasts"
  region  = "us-east-1"
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
    "staging"]
  }
  most_recent = true
}

resource "aws_instance" "cloudcasts_web" {
  ami           = data.aws_ami.app.id
  instance_type = "t3.small"
  root_block_device {
    volume_size = 8
    #GB
    volume_type = "gp3"
  }
  tags = {
    Name       = "cloudcasts.staging.io"
    Project    = "cloudcasts.io"
    Enviroment = "staging"
    ManagedBy  = "terraform"
  }
}
resource "aws_eip" "app_eip" {
  vpc = true
  lifecycle {
    #might bite you in the ass sometimes
    prevent_destroy = true
  }
  tags = {
    Name       = "cloudcasts-staging-web-address"
    Project    = "cloudcasts.io"
    Enviroment = "staging"
    ManagedBy  = "terraform"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id = aws_instance.cloudcasts_web.id

  allocation_id = aws_eip.app_eip.id

}