output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "subnet_availability_zone" {
  value = aws_subnet.subnet.availability_zone
}