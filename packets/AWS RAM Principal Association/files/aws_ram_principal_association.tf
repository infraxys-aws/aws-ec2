#if ($instance.getAttribute("resource_share_velocity_name") != "")
	#set ($rsInstance = $instance.byVelocity("resource_share_velocity_name"))
	#set ($tgwName = $rsInstance.parent.getAttribute("tgw_name"))
	#set ($rsName = $rsInstance.getAttribute("resource_share_name"))
	#set ($rsStateName = $rsInstance.getAttribute("state_name"))
	#set ($rsArnGet = "data.terraform_remote_state." + $rsStateName + ".outputs." + $rsName + "_arn")
#else
	#set ($tgwName = $instance.parent.getAttribute("tgw_name"))
	#set ($rsName = $instance.parent.getAttribute("resource_share_name"))
	#set ($rsArnGet = "aws_ram_resource_share." + $tgwName + ".arn")
#end

#set ($associationName = $instance.getAttribute("association_name"))
#set ($providerAlias = $instance.getAttribute("provider_alias")) 
#set ($providerLine = $instance.getAttribute("provider_line", ""))

resource "aws_ram_principal_association" "$associationName" {
  principal          = data.aws_caller_identity.${providerAlias}.account_id
  resource_share_arn = $rsArnGet
}

resource "aws_ram_resource_share_accepter" "${associationName}_accepter" {
  $providerLine
  depends_on = [
    aws_ram_principal_association.${associationName}
  ]
  share_arn = aws_ram_principal_association.${associationName}.resource_share_arn
}