#!/usr/bin/env python3.7

import os
from aws.elb.alb import Alb

if os.getenv("alb_hostname") != "" and os.getenv("route53_zone_name") != "":
    alb = Alb().from_environment()
    alb.retrieve_from_aws()
    alb.ensure_dns()
