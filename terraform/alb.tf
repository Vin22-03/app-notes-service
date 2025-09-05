resource "aws_lb" "notes_alb_v4" {
  name               = "notes-alb-v4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0cedc02bb50dd61e8"]
  subnets            = [
    "subnet-0c9e45bd7228d8e23",
    "subnet-0cd730e7a5a240b8d"
  ]

  lifecycle {
    ignore_changes = [security_groups]
    prevent_destroy = true
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
  vpc_id      = "vpc-0210ac57d9d16c303"
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

lifecycle {
  prevent_destroy = false
  ignore_changes  = [stickiness, deregistration_delay, slow_start, tags_all, security_groups]
}


  tags = {
    Name = "notes-tg-v4"
    Env  = "Dev"
  }
}
resource "aws_lb_target_group" "notes_tg_v4_green" {
  name        = "notes-tg-v4-green"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = "vpc-0210ac57d9d16c303"
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  lifecycle {
    ignore_changes = [
      stickiness,
      deregistration_delay,
      slow_start,
      tags_all
    ]
    prevent_destroy = false
  }

  tags = {
    Name = "notes-tg-v4-green"
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

  tags = {
    Name = "notes-listener-v4"
    Env  = "Dev"
  }

  depends_on = [aws_lb_target_group.notes_tg_v4]
}
