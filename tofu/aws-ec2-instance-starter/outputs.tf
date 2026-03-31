output "instance_id" {
  description = "Created EC2 instance id."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address."
  value       = aws_instance.this.public_ip
}

