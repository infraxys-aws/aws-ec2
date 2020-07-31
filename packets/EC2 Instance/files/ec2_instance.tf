#set ($vpcInstance = $instance.byVelocity("vpc_velocity_name"))
#set ($securityGroups = $instance.getInstancesByPacketType("SECURITY_GROUP"))
#set ($instanceProfile = $instance.getInstanceByPacketTypeAndAttributeValue("IAM_ROLE", "use_for_instance_profile", "1"))
#set ($instanceName = $instance.getAttribute("instance_name"))
#set ($imageId = $instance.getAttribute("image_id"))
#set ($isAmiId = $imageId.startsWith("ami-"))

#if (! $isAmiId)
  #set ($packerInstance = $instance.byVelocity("image_id", true, false))
  #if ($packerInstance) ## with Packer Instance and "ami-", we use the environment variable
    #set ($prefix = $packerInstance.getAttribute("ami_name_prefix") + "*")
  #else
  	#set ($prefix = $imageId)
  #end

data "aws_ami" "$instanceName" {
  most_recent      = true
  
  owners           = [$velocityUtils.doubleQuoteCsvList($instance.getAttribute("image_owners"))]

  filter {
    name   = "name"
    values = ["$prefix"]
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

#if ($instance.getAttribute("user_data_script") != "")
    #set ($hasUserData = true)
#else
    #set ($hasUserData = false)
#end

resource "aws_instance" "$instanceName" {
    instance_type = "$instance.getAttribute("instance_type")"
#if ($isAmiId)
    ami = "$imageId"
#else
    ami      = data.aws_ami.${instanceName}.id
#end
    key_name = "$instance.getAttribute("key_pair_name")"
    subnet_id = $instance.getAttribute("instance_subnet_id")
    associate_public_ip_address = $instance.getBoolean("associate_public_ip_address")
    disable_api_termination = $instance.getAttributeAsBoolean("disable_api_termination")
    vpc_security_group_ids = [
#foreach ($securityGroup in $securityGroups)
      aws_security_group.${securityGroup.getAttribute("security_group_name")}.id#if( $foreach.hasNext ),#end
    ]
#end
#if ($instanceProfile)	
    iam_instance_profile = "$instanceProfile.getAttribute("iam_role_name")"
#end
    tags = {
$instance.getAttribute("instance_tags")
    }
    
    root_block_device {
        volume_type = "$instance.getAttribute("root_block_device_type")"
        volume_size = "$instance.getAttribute("root_block_device_size")"
        delete_on_termination = $instance.getBoolean("root_block_device_del_on_term")
    }
#if ($hasUserData)    
    user_data           = data.template_file.user_data.rendered
#end
    lifecycle {
        prevent_destroy = $instance.getAttributeAsBoolean("prevent_destroy")
    }
}

#if ($hasUserData)
#[[
data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars = {
  }
}
]]#
#end

output "${instanceName}_private_ip" {
    value = aws_instance.${instanceName}.private_ip
}

output "${instanceName}_public_ip" {
    value = aws_instance.${instanceName}.public_ip
}

output "${instanceName}_public_dns" {
    value = aws_instance.${instanceName}.public_dns
}
