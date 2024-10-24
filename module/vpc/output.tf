output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub1" {
  value = aws_subnet.pub_sub1.id
}

output "pub_sub2" {
  value = aws_subnet.pub_sub2.id
}

output "pri_sub1" {
  value = aws_subnet.pri_sub1.id
}

output "pri_sub2" {
  value = aws_subnet.pri_sub2.id
}