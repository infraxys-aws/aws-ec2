resource "aws_ram_resource_association" "$instance.getAttribute("association_name")" {
  resource_arn       = $instance.getAttribute("resource_arn")
  resource_share_arn = $instance.getAttribute("resource_share_arn")
}