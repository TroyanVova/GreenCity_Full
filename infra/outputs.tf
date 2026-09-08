output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "node_security_group_id" {
  description = "ID of the k3s node-facing security group (SSH + NodePorts)."
  value       = aws_security_group.node.id
}

output "db_security_group_id" {
  description = "ID of the DB-facing security group (Postgres, internal only)."
  value       = aws_security_group.db.id
}

output "k3s_server_public_ip" {
  description = "Stable Elastic IP of the k3s server-node — SSH/SSM troubleshooting and the Jenkins SSH tunnel to 6443 both target this."
  value       = aws_eip.server.public_ip
}

output "alb_dns_name" {
  description = "Public ALB endpoint — this is the URL to open, not the EC2 IP."
  value       = aws_lb.app.dns_name
}

output "ecr_repository_urls" {
  description = "ECR repo URIs to push images to (docker tag / docker push targets)."
  value       = { for k, v in aws_ecr_repository.app : k => v.repository_url }
}

output "db_endpoint" {
  description = "RDS endpoint (host:port) — only reachable from app-sg, i.e. from the EC2 instance."
  value       = aws_db_instance.postgres.endpoint
}
