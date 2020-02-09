#!/usr/bin/env python3.7

import json

if __name__ == "__main__":
    from base_object import BaseObject
else:
    from .base_object import BaseObject


class Protocol():
    ALL = "-1"
    UDP = "17"
    TCP = "6"


class NetworkAcl(BaseObject):

    def __init__(self):
        super().__init__()

    def get_open_to_the_world_nacls(self, aws_profile_name=None):
        print("AWS profile: {}".format(aws_profile_name))
        response = self.get_client(aws_profile_name=aws_profile_name).describe_network_acls(
            Filters=[{'Name': "entry.cidr", 'Values': ['0.0.0.0/0'] }]
        )
        for nacl in response['NetworkAcls']:
            for entry in nacl['Entries']:
                if self.nacl_entry_is_world_inbound_ssh(entry):
                    self.process_ssh_nacl(aws_profile_name, nacl)
                    break # we don't need to check other rules since SSH was found

    def get_name_or_id(self, objectId, objectTags):
        for tag in objectTags:
            if tag["Key"].lower() == "name":
                return tag["Value"]

        return objectId

    def nacl_entry_is_world_inbound_ssh(self, entry):
        if not entry['Egress'] and entry["CidrBlock"] == "0.0.0.0/0" and entry['RuleAction'] == "allow":
            if entry['Protocol'] in [Protocol.TCP, Protocol.ALL]:
                portRange = ""

                if "PortRange" in entry:
                    portRange = entry["PortRange"]

                if portRange == "": # all ports
                    return True
                else:
                    if portRange["From"] <= 22 and portRange["To"] >= 22:
                        return True
                    else:
                        print("This is not SSH, so skipping", portRange)
                        return False

            elif entry['Protocol'] not in [Protocol.UDP]:
                print("--- new protocol: ",  entry['Protocol'])

    def process_ssh_nacl(self, aws_profile_name, nacl):
        default = " default" if nacl["IsDefault"] else ""

        print("Processing {}NACL '{}' with ingress 0.0.0.0/0 for SSH."
              .format(default, self.get_name_or_id(nacl['NetworkAclId'], nacl["Tags"])))

        subnet_ids = []
        for association in nacl["Associations"]:
            subnet_ids.append(association['SubnetId'])

        if len(subnet_ids) == 0:
            print("  this subnet has no associations, so ignoring it")
            return

        subnets = self.get_client(aws_profile_name=aws_profile_name).describe_subnets(
            SubnetIds=subnet_ids)

        subnetIds = []
        for subnet in subnets["Subnets"]:
            print("\tassociated subnet: {}".format(self.get_name_or_id(subnet['SubnetId'], subnet["Tags"])))
            subnetIds.append(subnet["SubnetId"])


        enis = self.get_client(aws_profile_name=aws_profile_name).describe_network_interfaces(
                Filters=[{'Name': "subnet-id", 'Values': subnetIds }])

        if len(enis["NetworkInterfaces"]) == 0:
            print("\t\tNo attached ENIs")
        else:
            print("\t\tAttached ENIs:")
            for eni in enis["NetworkInterfaces"]:
                print("\t\t\t{}".format(eni["Description"]))
                # print("   IpOwnerId: ", eni["IpOwnerId"])

        #print(enis)


if __name__ == "__main__":
    acl = NetworkAcl()
    aws_profile_names=[]
    for aws_profile_name in aws_profile_names:
        acl.get_open_to_the_world_nacls(aws_profile_name=aws_profile_name)
