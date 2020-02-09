#!/usr/bin/env python3.7

import os

from aws.ec2.network_acl import NetworkAcl

aws_profile_names = os.environ["aws_profile_names"]
acl = NetworkAcl()
for aws_profile_name in aws_profile_names.split(','):
    print("Using profile", aws_profile_name) 
    acl.get_open_to_the_world_nacls(aws_profile_name=aws_profile_name)
