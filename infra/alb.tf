resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  port        = 30080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "${var.project_name}-frontend-tg" }
}

resource "aws_lb_target_group" "backcore" {
  name        = "${var.project_name}-backcore-tg"
  port        = 30880
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "${var.project_name}-backcore-tg" }
}

resource "aws_lb_target_group" "backuser" {
  name        = "${var.project_name}-backuser-tg"
  port        = 30860
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "${var.project_name}-backuser-tg" }
}

locals {
  cluster_nodes = merge(
    { server = aws_instance.server.id },
    { for idx, inst in aws_instance.agent : "agent-${idx}" => inst.id },
  )
}

resource "aws_lb_target_group_attachment" "frontend" {
  for_each         = local.cluster_nodes
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = each.value
  port             = 30080
}

resource "aws_lb_target_group_attachment" "backcore" {
  for_each         = local.cluster_nodes
  target_group_arn = aws_lb_target_group.backcore.arn
  target_id        = each.value
  port             = 30880
}

resource "aws_lb_target_group_attachment" "backuser" {
  for_each         = local.cluster_nodes
  target_group_arn = aws_lb_target_group.backuser.arn
  target_id        = each.value
  port             = 30860
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backcore" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backcore.arn
  }

  condition {
    path_pattern {
      values = ["/core/*"]
    }
  }
}

resource "aws_lb_listener_rule" "backuser" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backuser.arn
  }

  condition {
    path_pattern {
      values = ["/user/*"]
    }
  }
}
