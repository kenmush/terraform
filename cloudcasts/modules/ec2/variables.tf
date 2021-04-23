variable "infra_env" {
  type = string
  description = "infrastructure enviroment"
}
variable "infra_role" {
  type = string
  description = "infrastructure purpose"
}
variable "instance_size" {
  type = string
  default = "t3.small"
}
variable "instance_ami" {
  type = string
  description = "server image to use"
}
variable "instance_root_device_size" {
  type = string
  default = 12
}

variable "subnets" {
  type = list(string)
  description = "valid subnets to assign to server"
}
variable "security_groups" {
  type = list(string)
  description = "security groups to assign to server"
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
  description = "tags for ec2 instance"
}
variable "create_eip" {
  type = bool
  default = false
  description = "whether to create an EIP for an EC2 instance"
}