#if ($instance.getAttribute("aws_profile") == "")
  #stop
#end

## We cannot use environment variables for the attributes here because 
##     this script is not run from this instance, but from a parent Terraform instance.
#set ($attachmentName = $instance.getAttribute("attachment_name"))
#set ($attachmentNameUnderscores = $attachmentName.replaceAll("-", "_"))

function tmp_init_vars() {
	local attachment_name="$attachmentName";
	local aws_profile="$instance.getAttribute("aws_profile")";
#[[
	log_info "Storing the current AWS environment.";
	local old_aws_profile="$AWS_PROFILE";
	local old_aws_default_region="$AWS_DEFAULT_REGION";
	local old_aws_secret_access_key="$AWS_SECRET_ACCESS_KEY";
	local old_aws_access_key_id="$AWS_ACCESS_KEY_ID";
	local old_aws_session_token="$AWS_SESSION_TOKEN";
	
	set_aws_profile --profile_name "$aws_profile";
]]#
	export TF_VAR_${attachmentNameUnderscores}_aws_access_key="${D}AWS_ACCESS_KEY_ID";
	export TF_VAR_${attachmentNameUnderscores}_aws_secret_key="${D}AWS_SECRET_ACCESS_KEY";
	export TF_VAR_${attachmentNameUnderscores}_aws_session_token="${D}AWS_SESSION_TOKEN";
	
	cat >> "${D}TERRAFORM_TEMP_DIR/attachments.tf" <<EOF

variable "${attachmentNameUnderscores}_aws_access_key" {}
variable "${attachmentNameUnderscores}_aws_secret_key" {}
variable "${attachmentNameUnderscores}_aws_session_token" {}
  
provider "aws" {
  alias = "$attachmentName"

  region     = "$instance.parent.getAttribute("aws_region")"
  access_key = var.${attachmentNameUnderscores}_aws_access_key
  secret_key = var.${attachmentNameUnderscores}_aws_secret_key
  token = var.${attachmentNameUnderscores}_aws_session_token
}	
	
EOF
#[[
	cat "$TERRAFORM_TEMP_DIR/attachments.tf"
	log_info "Restoring the previous AWS environment.";
	export AWS_PROFILE="$old_aws_profile";
	export AWS_DEFAULT_REGION="$old_aws_default_region";
	export AWS_SECRET_ACCESS_KEY="$old_aws_secret_access_key";
	export AWS_ACCESS_KEY_ID="$old_aws_access_key_id";
	export AWS_SESSION_TOKEN="$old_aws_session_token";
}

tmp_init_vars;
]]#