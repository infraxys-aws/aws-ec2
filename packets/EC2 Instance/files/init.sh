#set ($amiPrefixOrPackerInstanceName = $instance.getAttribute("instance_ami_or_packer_instance"))
#if ($amiPrefixOrPackerInstanceName.startsWith("ami-"))
    export TF_VAR_instance_ami="$amiPrefixOrPackerInstanceName";
    log_info "Using ami: ${D}TF_VAR_instance_ami"
#else
    #set ($packerInstance = $instance.getInstanceByAttributeVelocityName("instance_ami_or_packer_instance", true, false))
    #if ($packerInstance)
        #set ($prefix = $packerInstance.getAttribute("ami_name_prefix"))
    #else
        #set ($prefix = $amiPrefixOrPackerInstanceName)
    #end
    log_info "Retrieving latest ami with name prefix '$prefix'."
    get_ami --ami_name_prefix $prefix --target_variable_name source_ami;
    if [ -z "${D}source_ami" ]; then
        log_fatal "No AMI with prefix '${D}prefix' found.";
        exit 1;
    fi;
    log_info "Source ami: ${D}source_ami";
    export TF_VAR_instance_ami="${D}source_ami";
#end

