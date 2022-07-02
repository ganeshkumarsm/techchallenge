output "lb_target_group_arn" {
  value = aws_lb_target_group.ganesh_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.ganesh_lb.dns_name
}