data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  k3s_token_param = "/${var.project_name}/k3s/node-token"
}

resource "aws_iam_role" "node" {
  name = "${var.project_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "k3s_token_ssm" {
  name = "${var.project_name}-k3s-token-ssm"
  role = aws_iam_role.node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:PutParameter", "ssm:GetParameter"]
      Resource = "arn:aws:ssm:${var.aws_region}:*:parameter${local.k3s_token_param}"
    }]
  })
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.project_name}-node-profile"
  role = aws_iam_role.node.name
}

# --- server-node ---
locals {
  server_user_data = <<-EOF
    #!/bin/bash
    set -eux
    curl -sfL https://get.k3s.io | sh -

    for i in $(seq 1 30); do
      [ -f /var/lib/rancher/k3s/server/node-token ] && break
      sleep 5
    done

    TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
    aws ssm put-parameter \
      --region ${var.aws_region} \
      --name "${local.k3s_token_param}" \
      --type SecureString \
      --value "$TOKEN" \
      --overwrite
  EOF
}

resource "aws_instance" "server" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name
  key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null
  user_data              = local.server_user_data

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-k3s-server"
    Role = "server"
  }
}

resource "aws_eip" "server" {
  domain   = "vpc"
  instance = aws_instance.server.id

  tags = {
    Name = "${var.project_name}-k3s-server-eip"
  }
}

# --- agent-nodes ---
resource "aws_instance" "agent" {
  count                  = 2
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name
  key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    TOKEN=""
    for i in $(seq 1 30); do
      TOKEN=$(aws ssm get-parameter \
        --region ${var.aws_region} \
        --name "${local.k3s_token_param}" \
        --with-decryption \
        --query Parameter.Value \
        --output text 2>/dev/null || true)
      [ -n "$TOKEN" ] && [ "$TOKEN" != "None" ] && break
      sleep 10
    done

    curl -sfL https://get.k3s.io | \
      K3S_URL="https://${aws_instance.server.private_ip}:6443" \
      K3S_TOKEN="$TOKEN" \
      sh -
  EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-k3s-agent-${count.index}"
    Role = "agent"
  }

  depends_on = [aws_instance.server]
}
