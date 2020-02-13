#set ($loadBalancerName = $instance.getAttribute("load_balancer_name"))

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

