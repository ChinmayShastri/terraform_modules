#staging variables
variable "ami" {
    description = "define ami id"
    type = string
    default = "ami-0a5c3558529277641"
}
variable "region" {
    description = "define the cluster region"
    type = string
    default = "us-east-1"
  
}
variable "PATH_TO_PUBLIC_KEY" {
    description = "path to the public key"
    type = string
    default = "staging-key.pub"
  
}
