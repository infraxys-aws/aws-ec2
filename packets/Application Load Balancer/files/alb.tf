#set ($loadBalancerName = $instance.getAttribute("load_balancer_name"))

resource "aws_lb" "$loadBalancerName" {
    name                    = "$loadBalancerName"
    internal                = $instance.getBoolean("internal")
    load_balancer_type      = "application"
    subnets                 = $instance.getAttribute("load_balancer_subnets")
    security_groups         = $instance.getAttribute("load_balancer_security_group_ids")
    enable_deletion_protection = $instance.getBoolean("enable_deletion_protection")
    idle_timeout = 3600

#if ($instance.getAttribute("elb_access_log_bucket") != "")    
    access_logs {
        bucket              = "$instance.getAttribute("elb_access_log_bucket")"
        prefix              = "$instance.getAttribute("elb_access_log_bucket_prefix")"
        #interval            = "$instance.getAttribute("elb_access_log_interval")"
        enabled             = true
    }
#end

    tags = {
$instance.getAttribute("tags")
    }
}

