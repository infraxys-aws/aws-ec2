#if ($instance.parent.getAttribute("create_bastion", "0") == "0")
#stop
#end

#set ($vpcNamePrefix = $instance.parent.getAttribute("vpc_name_prefix"))
#set ($imageId = $instance.getAttribute("image_id"))
#set ($isAmiId = $imageId.startsWith("ami-"))

#if (! $isAmiId)
data "aws_ami" "bastion_ami" {
  most_recent      = true
#if ($instance.getAttribute("image_owners") != "")
  owners           = [$velocityUtils.doubleQuoteCsvList($instance.getAttribute("image_owners"))]
#end	
  filter {
    name   = "name"
    values = ["$imageId"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#end

resource "aws_launch_configuration" "bastion_lc" {
  name_prefix   = "${vpcNamePrefix}-"
#if ($isAmiId)
  image_id      = "$imageId"
#else
  image_id      = data.aws_ami.bastion_ami.id
#end
  instance_type = "$instance.getAttribute("instance_type")"
  key_name      = "$instance.getAttribute("key_pair_name")"
  associate_public_ip_address = true
  security_groups      = [
    "${D}{aws_security_group.bastion-sg.id}"
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                 = "$instance.getAttribute("bastion_name")"
  launch_configuration = "${D}{aws_launch_configuration.bastion_lc.name}"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
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

