variable "region"{
    description = "Define aws region"
    type = string 
}
variable "cluster_name"{
    description = "Define cluster name"
    type = string
}
variable "ami" {
    description = "Define ami"
    type = string
}
variable "instance_type" {
    description = "define instance type"
    type = string
}
variable "PATH_TO_PUBLIC_KEY" {
    description = "define public key path"
    type = string
}
variable "min_size" {
    description = "define min asg size"
    type = string
}
variable "max_size" {
    description = "define max asg size"
    type = string
}
