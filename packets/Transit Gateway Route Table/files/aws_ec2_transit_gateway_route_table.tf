#set ($routeTableName = $instance.getAttribute("route_table_name"))

resource "aws_ec2_transit_gateway_route_table" "$routeTableName" {
  transit_gateway_id = $instance.getAttribute("tgw_id_expression")
  tags = {
  	$instance.getAttribute("tags")
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "${routeTableName}-association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.${instance.parent.getAttribute("attachment_name")}.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.${routeTableName}.id
}


