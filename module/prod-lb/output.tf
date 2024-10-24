output "prod-dns" {
  value = aws_lb.prod-alb.dns_name
}

output "prod-zone-id" {
  value = aws_lb.prod-alb.zone_id
}

output "prod-tg-arn" {
  value = aws_lb_target_group.prod-tg.arn
}