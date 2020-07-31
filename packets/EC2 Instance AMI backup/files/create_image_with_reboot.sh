#set ($vpcInstance = $instance.byVelocity("vpc_velocity_name"))
vpc_name="$vpcInstance.getAttribute("vpc_name")";

#[[
create_aws_ami --vpc_name "$vpc_name" \
	--region "$aws_region" \
	--instance_name "$instance_name" \
	--name_prefix "$name_prefix" \
	--reboot "true" \
	--description "$description" \
	--retention "$retention";
]]#