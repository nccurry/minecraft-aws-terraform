def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name='us-west-2')
    response = ec2.start_instances(InstanceIds=['${var.ec2_instance_id}'])
import os
import json

def return_func(
    status_code=200,
    message="Invocation successful!",
    headers={"Content-Type": "application/json"},
    isBase64Encoded=False,
):
    return {
        "statusCode": status_code,
        "headers": headers,
        "body": json.dumps({"message": message}),
        "isBase64Encoded": isBase64Encoded,
    }
def lambda_handler(event, context):
    source_ip = event["requestContext"]["http"]["sourceIp"]
    allowlisted_cidr_ranges = os.environ.get("ALLOWLISTED_CIDR_RANGES", "").split(",")
    request_method = event["requestContext"]["http"]["method"]

    if not IP_RANGE:
        return return_func(status_code=500, message="Unauthorized")

    VALID_IP = check_ip(IP_ADDRESS, IP_RANGE)

    if not VALID_IP:
        return return_func(status_code=500, message="Unauthorized")

    if METHOD == "GET":
        return return_func(status_code=200, message="GET method invoked!")

    if METHOD == "POST":
        return return_func(status_code=200, message="POST method invoked!")

    return return_func()