output "stage-dns" {
  value = aws_lb.stage-alb.dns_name
}

output "stage-zone-id" {
  value = aws_lb.stage-alb.zone_id
}

output "stage-tg-arn" {
  value = aws_lb_target_group.stage-tg.arn
}