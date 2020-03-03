#set ($amiPrefixOrPackerInstanceName = $instance.getAttribute("instance_ami"))
#if ($amiPrefixOrPackerInstanceName.startsWith("ami-"))
    export TF_VAR_instance_ami="$amiPrefixOrPackerInstanceName";
    log_info "Using ami: ${D}TF_VAR_instance_ami"
#else

    #set ($packerInstance = $instance.byVelocity("instance_ami", true, false))
    #if ($packerInstance)
        #set ($prefix = $packerInstance.getAttribute("ami_name_prefix"))
    #else
        #set ($prefix = $amiPrefixOrPackerInstanceName)
    #end
    #set ($amiType = $instance.getAttribute("ami_type"))
#if ($amiType == "all")
    log_info "Retrieving latest public ami with name prefix '$prefix'."
    get_ami --ami_name_prefix $prefix --owner all --target_variable_name source_ami --executable_users all;
#else
    log_info "Retrieving latest ami with name prefix '$prefix'."
    get_ami --ami_name_prefix $prefix --target_variable_name source_ami;
#end
    if [ -z "${D}source_ami" ]; then
        log_fatal "No AMI with prefix '$prefix' found.";
        exit 1;
    fi;
    log_info "Source ami: ${D}source_ami";
    export TF_VAR_instance_ami="${D}source_ami";
#end

