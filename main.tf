

# locals {
#   subnet_ids = toset([
#     aws_subnet.public_subnet[0].id,
#     aws_subnet.public_subnet[1].id
#   ])
# }


provider "aws" {
 # region = var.region
 region = "ap-south-1"
}

module "my_vpc" {
    source      = "./modules/vpc"
    vpc_cidr = var.m_vpc_cidr
    public_subnet_cidr_blocks = var.m_public_subnet_cidr_blocks
    private_subnet_cidr = var.m_private_subnet_cidr
    env = var.m_env
}

module "my_sg" {
    source      = "./modules/sg"
    vpcId = "${module.my_vpc.vpc_Id}"
    env = var.m_env
}

module "my_ec2" {
    source        = "./modules/instance"
    InstanceType = var.m_InstanceType
    sg_id = "${module.my_sg.sg_Id}"
 
    pub_sbnt_id = "${module.my_vpc.pub_sub_Id}"
    private_nat_sg = "${module.my_sg.sg_nat_Id}"
    private_sbnt_id = "${module.my_vpc.privt_sub_Id}"

    env = var.m_env
}

module "my_lb" {
    source      = "./modules/lb"
    env = var.m_env
    sG = "${module.my_sg.sG_id}"
    sbnts = "${module.my_vpc.sbnts_id}"
    vpc_Id = "${module.my_vpc.vpc_Id}"
    aws_inst = "${module.my_ec2.aws_inst_cnt}"


}