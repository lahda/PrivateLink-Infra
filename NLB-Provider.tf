resource "aws_lb" "provider" {
  name               = "${var.project_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.provider_private[*].id

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = true

  tags = merge(
    local.common_tags,
    {
      Name = "NLB-IT-PrivateLink"
    }
  )
}

# Target Group
resource "aws_lb_target_group" "api" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.provider.id

  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }

  tags = merge(
    local.common_tags,
    {
      Name = "TG-API-IT-PrivateLink"
    }
  )
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "api" {
  count            = 2
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.api_server[count.index].id
  port             = 80
}

# NLB Listener
resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.provider.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = merge(
    local.common_tags,
    {
      Name = "NLB-Listener-80"
    }
  )
}
