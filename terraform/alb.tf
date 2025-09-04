resource "aws_lb" "notes_alb_v4" {
  name               = "notes-alb-v4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0cedc02bb50dd61e8"] # ✅ Matches real AWS SG
  subnets            = aws_subnet.public[*].id

  lifecycle {
    ignore_changes = [security_groups] # Prevent recreate due to SG mismatch
  }

  tags = {
    Name = "notes-alb-v4"
    Env  = "Dev"
  }
}

resource "aws_lb_target_group" "notes_tg_v4" {
  name        = "notes-tg-v4"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # ✅ Required for Fargate

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      stickiness,
      deregistration_delay,
      slow_start,
      tags_all
    ]
  }

  tags = {
    Name = "notes-tg-v4"
    Env  = "Dev"
  }
}

resource "aws_lb_listener" "notes_listener_v4" {
  load_balancer_arn = aws_lb.notes_alb_v4.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notes_tg_v4.arn
  }

  depends_on = [aws_lb_target_group.notes_tg_v4]

  tags = {
    Name = "notes-listener-v4"
    Env  = "Dev"
  }
}
