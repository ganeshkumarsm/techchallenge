output "vpc_id" {
  value = aws_vpc.ganesh_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.ganesh_rds_subnet_group.*.name
}

output "db_security_group" {

  value = aws_security_group.ganesh_ingress_sg["RDS"].id
}

output "public_sg" {
  value = aws_security_group.ganesh_ingress_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.ganesh_public_subnet.*.id
}