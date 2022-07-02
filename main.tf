#private_sn_count = 2  to cover minimum 2 azs for rds subnet group

module "networking" {
  source           = "./networking"
  cidr_block       = "10.10.0.0/16"
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  max_subnets      = 20
  public_sn_count  = 2
  private_sn_count = 2 
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
}

module "loadbalancing" {
  source                  = "./loadbalancing"
  public_sg               = module.networking.public_sg
  public_subnets          = module.networking.public_subnets
  tg_port                 = 8080
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  elb_healthy_threshold   = 3
  elb_unhealthy_threshold = 3
  elb_timeout             = 3
  elb_interval            = 30
  listener_port           = 80
  listener_protocol       = "HTTP"
}

module "database" {
  source = "./database"
  db_storage = 10 
  db_engine_version = "5.7.22"
  db_instance_class = "db.t2.micro"
  dbname = var.dbname
  dbuser = var.dbuser
  dbpassword = var.dbpassword
  dbidentifier = "ganesh-db"
  db_subnet_group_name = module.networking.db_subnet_group_name[0]
  skip_db_snapshot = true
  vpc_security_group_ids = [module.networking.db_security_group]

}

module "compute" {
  source         = "./compute"
  public_sg      = module.networking.public_sg
  public_subnets = module.networking.public_subnets
  instance_count = 2
  instance_type  = "t3.micro"
  vol_size       = "20"
  key_name        = "id_rsa"
  user_data_path  = "${path.root}/userdata.tpl"
  dbname = var.dbname
  dbuser = var.dbuser
  dbpassword = var.dbpassword
  db_endpoint = module.database.db_endpoint
  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
}