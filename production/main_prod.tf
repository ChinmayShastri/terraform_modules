module "stagin_group" {
    source = "../modules_main"
    region = var.region
    cluster_name = production
    ami = var.ami
    instance_type = t2.micro
    PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
    min_size = 1
    max_size = 4

}