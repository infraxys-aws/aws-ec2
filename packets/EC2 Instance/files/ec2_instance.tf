#set ($vpcInstance = $instance.byVelocity("vpc_velocity_name"))
#set ($securityGroups = $instance.getInstancesByPacketType("SECURITY_GROUP"))
#set ($instanceProfile = $instance.getInstanceByPacketTypeAndAttributeValue("IAM_ROLE", "use_for_instance_profile", "1"))

#if ($instance.getAttribute("user_data_script") != "")
    #set ($hasUserData = true)
#else
    #set ($hasUserData = false)
#end

# instance_ami is set through the init.sh script which will figure out which AMI to use
variable "instance_ami" {
    type="string"
}

resource "aws_instance" "$instance_name" {
    instance_type = "$instance.getAttribute("instance_type")"
    ami = "${D}{var.instance_ami}"
    key_name = "$instance.getAttribute("key_pair_name")"
    subnet_id = $instance.getAttribute("instance_subnet_id")
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

output "${instance_name}_private_ip" {
    value = aws_instance.${instance_name}.private_ip
}
