data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] 
  }
}

resource "random_id" "instance_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "instance_auth" {
  key_name   = var.key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCys87+Qj41ZqlqgJysB8e0qMPwBZe0XRALQ+ZZgE1bVrpFuITXclJ+Hlbxw6YrFpe59F6EwxN8jZoZunQ8tzfGzePJ538v26p4nVot+ABWaDrcB60QJaJrYTH8ljetASEVcxvMH3HdKY7ZoWiLb+lxid+ePezfGCPeaodhT0Q+l1FRSdTcGVUl727EOCKV7EgN8+ovzaEeJPYhefaM/OHKCfedXZeTfzindBaa7oijxS5Hm1kz/NdK30UNWn22l8wIxej6iSJk4Zr9m3fdwynOXmYxcDCF/xIzNWVqsXTpCMS2a7zTSa2XNyDQoZy59Rt6bK58vt0RnjPR6sp341JN Ganesh@DESKTOP-I9SPTAF"
}


resource "aws_instance" "kube_node" {
  count         = var.instance_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id

  tags = {
    Name = "kube_node-${random_id.instance_node_id[count.index].dec}"
  }

  # key_name               = ""
  key_name               = aws_key_pair.instance_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  # user_data              = ""
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "kube_node-${random_id.instance_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      dbname      = var.dbname
    }
  )

  root_block_device {
    volume_size = var.vol_size
  }
}

resource "aws_lb_target_group_attachment" "ganesh_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.kube_node[count.index].id
  port             = 8080
}
