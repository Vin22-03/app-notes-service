resource "aws_lb" "notes_alb" {
  name               = "notes-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "notes_tg" {
  name     = "notes-tg-v2"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type  = "ip" # ✅ ADD THIS LINE for Fargate compatibility

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "notes_listener" {
  load_balancer_arn = aws_lb.notes_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notes_tg.arn
  }
depends_on = [aws_lb_target_group.notes_tg]
}


