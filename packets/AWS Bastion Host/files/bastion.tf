#if ($instance.parent.getAttribute("create_bastion", "0") == "0")
#stop
#end

#set ($vpcNamePrefix = $instance.parent.getAttribute("vpc_name_prefix"))

resource "aws_launch_configuration" "bastion_lc" {
  name_prefix   = "${vpcNamePrefix}-"
  image_id      = "$image_id"
  instance_type = "$instance_type"
  key_name      = "$key_pair_name"
  associate_public_ip_address = true
  security_groups      = [
    "${D}{aws_security_group.bastion-sg.id}"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                 = "$bastion_name"
  launch_configuration = "${D}{aws_launch_configuration.bastion_lc.name}"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  ##vpc_zone_identifier  = ["${D}{module.vpc.public_subnets}"]
  vpc_zone_identifier = module.vpc.public_subnets

  health_check_grace_period = "60"
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }
  tags = [
$propagated_tag_list
]
  
}
