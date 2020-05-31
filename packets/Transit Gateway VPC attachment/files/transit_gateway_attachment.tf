#set ($tgwInstance = $instance.byVelocity("transit_gateway_velocity_name", false, false))
#if ($tgwInstance)
	#set ($tgwName = $tgwInstance.getAttribute("tgw_name"))
	#set ($tgwArnGet = "data.terraform_remote_state." + $tgwName + "-state.outputs.arn")
	#set ($tgwIdGet = "data.terraform_remote_state." + $tgwName + "-state.outputs.id")
#else
	#set ($tgwName = $instance.parent.getAttribute("tgw_name"))
	#set ($tgwArnGet = "aws_ec2_transit_gateway." + $tgwName + ".arn")
	#set ($tgwIdGet = "aws_ec2_transit_gateway." + $tgwName + ".id")
#end
#set ($attachmentName = $instance.getAttribute("attachment_name"))
#set ($stateInstance = $instance.byVelocity("vpc_state_velocity_name", false, false))

#if ($stateInstance)
    #set ($tgaVpcStateName = $stateInstance.getAttribute("state_name"))
    #set ($subnetIds = "data.terraform_remote_state." + $tgaVpcStateName + ".outputs.private_subnets")
	#set ($vpcId = "data.terraform_remote_state." + $tgaVpcStateName + ".outputs.vpc_id")
#else
	#set ($subnetIds = "[ " + $instance.getAttribute("subnet_ids") + " ]")
	#set ($vpcId = '"' + $instance.getAttribute("vpc_id") + '"')
#end

#set ($providerLine = $instance.getAttribute("provider_line", ""))
#if ($providerLine != "")
  
## accept the attachment in the other account that we create below 
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "$attachmentName" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.${attachmentName}.id

  tags = {
    $instance.getAttribute("attachment_tags")
  }
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.${attachmentName}
  ]
}
#end

resource "aws_ec2_transit_gateway_vpc_attachment" "$attachmentName" {
  $providerLine
  subnet_ids         = $subnetIds 
  transit_gateway_id = $tgwIdGet
  vpc_id             = $vpcId
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
