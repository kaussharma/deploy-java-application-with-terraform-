# 
# Variables Configuration
#
variable "aws_access_key" {
  type = "string"
  description  = "Insert aws access key"
  default = "AKIAJNYA475AZHGN3N7Q"
}
variable "aws_secret_key" {
  type = "string"
  description  = "Insert aws secret key"
  default = "gZ2KYtHQHbE2uQzEFptsoTVlKn3dUX5UzZzgd8IO"
}

variable "key_name" {
default = "ec2-machine_key"

}

variable "cluster-name" {
  default = "terraform-tw-demo-node"
  type    = "string"
}



