
resource "aws_alb" "alb" {  
  name            = "aws-tw-demo-alb"  
  subnets         = ["${aws_subnet.demo.*.id}"]
  security_groups = ["${aws_security_group.demo-node.id}"]
  internal        = "false"  
  load_balancer_type = "application"
  idle_timeout    = "180"   
  tags {    
    Name    = "aws-tw-demo-alb"    
  }   
  
}


resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_alb.alb.arn}"  
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = ["aws_alb_target_group.alb_target_group"]  
  listener_arn = "${aws_alb_listener.alb_listener.arn}"  
    
  action {    
    type             = "forward"    
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"  
  }   
  condition {    
    field  = "path-pattern"    
    values = ["/ping/"]  
  }
}


resource "aws_alb_target_group" "alb_target_group" {  
  name     = "elb-tw-demo"  
  port     = "8080"  
  protocol = "HTTP" 
  target_type = "ip" 
  vpc_id   = "${aws_vpc.demo.id}"   
  tags {    
    name = "alb_target_group"    
  }   
     
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/ping"    
    port                = "8080"  
  }
}

resource "aws_alb_target_group_attachment" "alb_target_group_attachment" {
  count            = "${aws_instance.primary.count}"
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${data.aws_instances.instances.private_ips[count.index]}"
  port             = 8080
}