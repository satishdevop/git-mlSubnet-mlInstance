resource "aws_lb" "appl" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = aws_subnet.public_subnet.*.id
   security_groups    = [var.sG]
   subnets            = var.sbnts

  //enable_deletion_protection = true  
  tags = {
     Name = "alb-${var.env}"
    
    environment = var.env
  }
}
resource "aws_lb_listener" "appl" {
  load_balancer_arn = aws_lb.appl.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-lb"
  port     = 80
  protocol = "HTTP"
  #vpc_id   = aws_vpc.vpc.id
  vpc_id   = var.vpc_Id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
    path = "/test.html"
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  #count            = length(aws_instance.blue)
  count            = (length(var.aws_inst)+1)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = data.aws_instances.bluein.ids[count.index]
  port             = 80
}

