#set ($inVpcConfig = $instance.getParentInstanceByPacketType("AWS_VPC"))
#if ($extra_terraform)
$extra_terraform
#end

resource "aws_security_group" "$security_group_name" {
    name = "$security_group_name"
    description = "$instance.getAttribute("description")"
    $instance.getAttribute("ingress_rules")
    $instance.getAttribute("egress_rules")
    tags = {
$tags
    }
#if ($inVpcConfig)
    vpc_id = module.vpc.vpc_id
#else
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
#end
}

output "${security_group_name}_id" {
  description = "The ID of the security group created."
  value       = aws_security_group.${security_group_name}.id
}
