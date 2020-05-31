#set ($tgwName = $instance.getAttribute("tgw_name"))

resource "aws_ec2_transit_gateway" "$tgwName" {
  description = "$instance.getAttribute("tgw_description")"
  amazon_side_asn = "$instance.getAttribute("amazon_side_asn")"
  auto_accept_shared_attachments = "$instance.getAttribute("auto_accept_shared_attachments")"
  default_route_table_association = "$instance.getAttribute("default_route_table_association")"
  default_route_table_propagation = "$instance.getAttribute("default_route_table_propagation")"
  dns_support = "$instance.getAttribute("dns_support")"
  vpn_ecmp_support = "$instance.getAttribute("vpn_ecmp_support")"
  tags = {
  	$instance.getAttribute("tgw_tags")
  }
}

output "arn" {
	value = "${D}{aws_ec2_transit_gateway.${tgwName}.arn}"
	description = "EC2 Transit Gateway Amazon Resource Name (ARN)"
}
	
output "association_default_route_table_id" {
	value = "${D}{aws_ec2_transit_gateway.${tgwName}.association_default_route_table_id}"
	description = "Identifier of the default association route table"
}

output "id" {
	value = "${D}{aws_ec2_transit_gateway.${tgwName}.id}"
	description = "EC2 Transit Gateway identifier"
}

output "owner_id" {
	value = "${D}{aws_ec2_transit_gateway.${tgwName}.owner_id}"
	description = "Identifier of the AWS account that owns the EC2 Transit Gateway"
}

output "propagation_default_route_table_id" {
	value = "${D}{aws_ec2_transit_gateway.${tgwName}.propagation_default_route_table_id}"
	description = "Identifier of the default propagation route table"
}


