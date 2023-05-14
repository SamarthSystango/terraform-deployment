variable "region" {
  type = string
  default = "us-east-1"
}

variable "ami" {
  type = string
  default = "ami-0123456789abcdef0"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
