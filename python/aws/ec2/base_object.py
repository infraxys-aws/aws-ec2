import boto3, os
# from aws.aws_base_object import AwsBaseObject


class BaseObject():

    def __init__(self):
        super().__init__()
        self._session = {}
        self._client = None

    def get_session(self, aws_profile_name=None):
        if aws_profile_name:
            p = aws_profile_name
        else:
            p = os.environ["AWS_PROFILE"]

        if not p:
            raise Exception("Unable to use an AWS profile because argument 'aws_profile_name' is empty and environment variable AWS_PROFILE is not set.")

        if not p in self._session:
            self._session[p] = boto3.Session(profile_name=p)

        return self._session[p]

    def get_client(self, aws_profile_name=None):
        if not self._client:
            self._client = self.get_session(aws_profile_name=aws_profile_name).client('ec2')

        return self._client
