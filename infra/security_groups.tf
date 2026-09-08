resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Public HTTP entrypoint for the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.app_ingress_port
    to_port     = var.app_ingress_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound (to the app instance)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "node" {
  name        = "${var.project_name}-node-sg"
  description = "SSH (restricted) + NodePorts reachable only from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin IP only (also carries the Jenkins tunnel to 6443)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }

  ingress {
    description     = "Frontend NodePort from ALB only"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "backcore NodePort from ALB only"
    from_port       = 30880
    to_port         = 30880
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "backuser NodePort from ALB only"
    from_port       = 30860
    to_port         = 30860
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # --- внутрішній k3s-трафік між нодами кластера (server<->agent) ---
  # Без цих self-referencing правил агенти не можуть приєднатись до
  # сервера по приватній IP:6443 -- SG за замовчуванням блокує навіть
  # трафік між власними членами, поки явно не дозволити.
  ingress {
    description = "k3s API (join + control-plane traffic) between cluster nodes"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Flannel VXLAN overlay between cluster nodes"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "kubelet API between cluster nodes (apiserver to kubelet, metrics-server, exec-logs)"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-node-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Postgres, reachable only from the k3s node security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from k3s nodes only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.node.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}
