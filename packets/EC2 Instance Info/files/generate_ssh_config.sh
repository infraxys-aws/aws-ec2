function _generate_config() {
    local instance_name="$instance.getAttribute("instance_name")"
    local ssh_connect_username="$instance.getAttribute("ssh_connect_username")"
    local vpc_name="$container.getAttribute("aws_vpc_name")";
    local bastion_name="$container.getAttribute("aws_vpc_bastion_name")";
    local private_key_file="$instance.getAttribute("private_key_file")";
    local aws_region="$instance.getAttribute("aws_region")";
#[[	
	local function_name="_generate_config" target_variable_name private_ip;
	import_args "$@";
	check_required_arguments "$function_name" target_variable_name;

	get_instance_private_ip --region "$aws_region" --vpc_name "$vpc_name" --instance_name "$instance_name" --target_variable_name private_ip;
    local proxy_command="ProxyCommand ssh $bastion_name -W %h:%p";
	local _generate_config_result=$(cat << EOF 
Host $instance_name
    Hostname $private_ip
    User $ssh_connect_username
    $proxy_command
    IdentityFile "$private_key_file"
    
EOF
);
	eval "$target_variable_name='$_generate_config_result'";
}

if [ "$initial_script_name" == "get_ssh_config.sh" ]; then # run directly
	result="";
	_generate_config --target_variable_name result;
	echo
	echo "$result";
	echo
else
	_generate_config "$@";
fi;

]]#

