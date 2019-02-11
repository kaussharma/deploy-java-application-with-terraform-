# 
# Variables Configuration
#
variable "aws_access_key" {
  type = "string"
  description  = "Insert aws access key"
  default = ""
}
variable "aws_secret_key" {
  type = "string"
  description  = "Insert aws secret key"
  default = ""
}

variable "key_name" {
default = "ec2-machine_key"

}

variable "cluster-name" {
  default = "terraform-tw-demo-node"
  type    = "string"
}



