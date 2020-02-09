#set ($tgwName = $instance.getAttribute("tgw_name"))
#set ($attachmentName = $instance.getAttribute("attachment_name"))
## vpc state name should be unique because we can have multiple vpc configs under one transit gateway 
#set ($vpcInstance = $instance.byVelocity("vpc_velocity_name"))
#set ($vpcStateName = $vpcInstance.getAttribute("vpc_name"))

data "terraform_remote_state" "$vpcStateName" {
$vpcInstance.getAttribute("remote_state_hcl")
}

resource "aws_ec2_transit_gateway_vpc_attachment" "$attachmentName" {
  subnet_ids         = data.terraform_remote_state.${vpcStateName}.outputs.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.${tgwName}.id
  vpc_id             = data.terraform_remote_state.${vpcStateName}.outputs.vpc_id
  dns_support        = "$instance.getAttribute("dns_support")"
  ipv6_support        = "$instance.getAttribute("ipv6_support")"
  transit_gateway_default_route_table_association        = $instance.getBoolean("transit_gateway_default_route_table_association")
  transit_gateway_default_route_table_propagation        = $instance.getBoolean("transit_gateway_default_route_table_propagation")
  tags = {
  	$instance.getAttribute("attachment_tags")
  }
}

output "${attachmentName}_id" {
	value = "${D}{aws_ec2_transit_gateway_vpc_attachment.${attachmentName}.id}"
	description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
}

output "${attachmentName}_vpc_owner_id" {
	value = "${D}{aws_ec2_transit_gateway_vpc_attachment.${attachmentName}.vpc_owner_id}"
	description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
}
