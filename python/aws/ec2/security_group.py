from .ec2_base_object import BaseObject

class SecurityGroup(BaseObject):

    def __init__(self):
        super().__init__()
        print("In Security group init")

    def list_all(self):
        # json = self.get_client().describe_vpcs(Filters=[self.get_name_filter(name=self.vpc_name) ])
        json = self.get_client().describe_security_groups()
        print(json)
