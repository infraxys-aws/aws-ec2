# We need to run init.sh here if this module is run directly
#	otherwise the running parent instance will execute init.sh

function run_init_if_required() {
	local this_instance_guid="$instance.getGuid()";
#[[	
	if [ "$this_instance_guid" == "$INSTANCE_GUID" ]; then
		. ./init.sh;	
	fi;
}

run_init_if_required;
]]#
