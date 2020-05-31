#set ($resourceShareName = $instance.getAttribute("resource_share_name"))

resource "aws_ram_resource_share" "$resourceShareName" {
  name = "$resourceShareName"
  allow_external_principals = $instance.getBoolean("allow_external_principals")
  tags = {
  	$instance.getAttribute("share_tags")
  }
}

output "${resourceShareName}_arn" {
	value = aws_ram_resource_share.${resourceShareName}.arn
	description = "RAM resource share ARN"
}


output "${resourceShareName}_id" {
	value = aws_ram_resource_share.${resourceShareName}.id
	description = "RAM resource share ID"
}
