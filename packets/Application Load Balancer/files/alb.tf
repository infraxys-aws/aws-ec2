#set ($loadBalancerName = $instance.getAttribute("load_balancer_name"))
#set ($inVpcConfig = $instance.getParentInstanceByPacketType("AWS_VPC"))
#set ($ec2Instance = $instance.getInstanceByAttributeVelocityName("load_balancer_attach_instance_vn"))
#if ($inVpcConfig)
  #set ($vpcId = "module.vpc.outputs.vpc_id")
#else
  #set ($vpcId = "data.terraform_remote_state.vpc.outputs.vpc_id")
#end

resource "aws_lb" "$loadBalancerName" {
    name                    = "$loadBalancerName"
    internal                = false
    load_balancer_type      = "application"
    subnets                 = $instance.getAttribute("load_balancer_subnets")
    security_groups         = $instance.getAttribute("load_balancer_security_group_ids")
    enable_deletion_protection = $instance.getBoolean("enable_deletion_protection")
    idle_timeout = 3600
    
    #access_logs {
    #    bucket              = "someinstance.getAttribute("terraform_state_bucket")"
    #    prefix              = "application-elb-logs"
    #    enabled             = false
    #}

    tags = {
$instance.getAttribute("tags")
    }
}

resource "aws_alb_listener" "alb_https_listener" {  
  load_balancer_arn = aws_lb.${loadBalancerName}.arn
  port              = "443"  
  protocol          = "HTTPS"
  
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "$instance.getAttribute("load_balancer_certificate_arn")"

  default_action {    
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"  
  }
}

resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = aws_lb.${loadBalancerName}.arn
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = [aws_alb_target_group.alb_target_group]  
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = "100"   
  condition {
    field  = "path-pattern"
    values = ["*"]
  }
  action {    
    type             = "forward"    
    target_group_arn = aws_alb_target_group.alb_target_group.id
  }
}

resource "aws_alb_target_group" "alb_target_group" {  
  name     = "${loadBalancerName}-tg"  
  port     = "8443"  
  protocol = "HTTPS"
  vpc_id = $vpcId

    tags = {
$instance.getAttribute("tags")
    }
  
  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 1800    
    enabled         = "true"  
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/index.jsp"    
    port                = "8082"
    matcher             = "302"
  }
}

resource "aws_alb_target_group_attachment" "alb_target_group_att" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_instance.${ec2Instance.getAttribute("instance_name")}.id
  port             = 8443
}


resource "aws_alb_target_group" "alb_tg_admin" {
  name     = "${loadBalancerName}-admin-tg"
  port     = "8082"
  protocol = "HTTP"
  vpc_id = $vpcId

    tags = {
$instance.getAttribute("tags")
    }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = "true"
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/healthcheck"
    port                = "8082"
    matcher             = "200"
  }
}

resource "aws_alb_listener" "alb_listener_admin" {
  load_balancer_arn = aws_lb.${loadBalancerName}.arn
  port              = "8443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "$instance.getAttribute("load_balancer_certificate_arn")"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg_admin.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule_admin" {
  depends_on   = ["aws_alb_target_group.alb_tg_admin"]
  listener_arn = aws_alb_listener.alb_listener_admin.arn
  priority     = "100"
  condition {
    field  = "path-pattern"
    values = ["*"]
  }
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_tg_admin.id
  }
}

resource "aws_alb_target_group_attachment" "alb_tg_att_admin" {
  target_group_arn = aws_alb_target_group.alb_tg_admin.arn
  target_id        = aws_instance.${ec2Instance.getAttribute("instance_name")}.id
  port             = 8082
}