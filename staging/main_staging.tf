provider "aws" {
  region     = var.region
}

module "stagin_group" {
    source = "../modules_main"
    region = var.region
    cluster_name = staging
    ami = var.ami
    instance_type = vat.instance_type
    PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
    min_size = 1
    max_size = 4

}