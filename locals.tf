locals {
  vpc_cidr = "10.10.0.0/16"
}
## Allows to dynamically construct the ingress security groups in the networking module.
locals {
  security_groups = {
    public = {
      name        = "public sg1"
      description = "allow public access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]

        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]

        }
        nginx = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    RDS = {
      name        = "RDS sg1"
      description = "allow RDS"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]

        }

      }
    }
  }
}