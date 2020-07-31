export PYTHONPATH="$(pwd)/python:$PYTHONPATH";

function create_aws_ami() {
    local reboot=true vpc_name region instance_name name_prefix description retention;
    import_args "$@";
    check_required_arguments "create_aws_snapshot" reboot vpc_name region instance_name name_prefix description retention;

    local full_name="$name_prefix/$(date +"%d-%m-%Y/%H-%M-%S")";
    echo "Full name: --$full_name--"

    if [ "$reboot" == "true" ]; then
        reboot_option="--reboot";
    else
        reboot_option="--no-reboot"
    fi;

    local _instance_id _tags;
    get_instance_id --instance_name "$instance_name" --region "$region" --vpc_name "$vpc_name" \
        --target_variable_name _instance_id;

    get_tags --instance_name "$instance_name" --region "$region" --vpc_name "$vpc_name" \
        --target_variable_name _tags;

    response="$(aws ec2 create-image --description "$description" \
        --instance-id "$_instance_id" \
        --name "$full_name" \
        $reboot_option)";


    local image_id="$(echo "$response" | jq -r '.ImageId')";
    log_info "image_id: $image_id";

    log_info "Applying instance tags to AMI";
    aws ec2 create-tags --resources "$image_id" --tags "$_tags"

    log_info "Applying additional tags to AMI";
    aws ec2 create-tags --resources "$image_id" --tags "Key=instance_id,Value=$_instance_id"
    aws ec2 create-tags --resources "$image_id" --tags "Key=Key=instance_name,Value=$instance_name"
    aws ec2 create-tags --resources "$image_id" --tags "Key=vpc_name,Value=$vpc_name"

    log_info "Retrieving existing backups";
    local response="$(aws ec2 describe-images --region "$region"  \
            --filters "Name=tag:instance_id,Values=$_instance_id")";

    echo "Response:"
    echo "$response"
    log_warn "TODO: delete old AMI backups";
}