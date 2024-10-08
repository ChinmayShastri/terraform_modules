provider "aws" {
  region     = var.region
}

module "stagin_group" {
    source = "../modules_main"
    region = var.region
    cluster_name = var.cluster_name
    ami = var.ami
    instance_type = var.instance_type
    PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
    min_size = 1
    max_size = 4

}