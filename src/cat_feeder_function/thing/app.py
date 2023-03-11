import os
import boto3
import json 
from botocore.exceptions import ClientError
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient

def lambda_handler(event, context):
    # print(event)

    secret_name_cert_ca = os.environ['CatFeederCA']
    secret_name_cert_crt = os.environ['CatFeederCertificatePEM']
    secret_name_cert_private = os.environ['CatFeederPrivateKey']
    region_name = os.environ['AWS_REGION']
    
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
    )

    try:
        get_secret_value_cert_ca_response = client.get_secret_value(SecretId=secret_name_cert_ca)
        get_secret_value_cert_crt_response = client.get_secret_value(SecretId=secret_name_cert_crt)
        get_secret_value_cert_private_response = client.get_secret_value(SecretId=secret_name_cert_private)
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        else:
            print(e)
    else:
        text_secret_data_cert_ca = get_secret_value_cert_ca_response['SecretString']
        text_secret_data_cert_crt = get_secret_value_cert_crt_response['SecretString']
        text_secret_data_cert_private = get_secret_value_cert_private_response['SecretString']

        # print(text_secret_data_cert_ca)
        # print(text_secret_data_cert_crt)
        # print(text_secret_data_cert_private)


        with open('/tmp/root_ca.pem', 'w') as the_file:
            the_file.write(text_secret_data_cert_ca)

        with open('/tmp/device_cert.crt', 'w') as the_file:
            the_file.write(text_secret_data_cert_crt)

        with open('/tmp/private_key.key', 'w') as the_file:
            the_file.write(text_secret_data_cert_private)

        myMQTTClient = AWSIoTMQTTClient(os.environ['ThingName'])
        myMQTTClient.configureEndpoint(os.environ['IoTEndpoint'], 8883)
        myMQTTClient.configureCredentials("/tmp/root_ca.pem", "/tmp/private_key.key", "/tmp/device_cert.crt")
        myMQTTClient.configureOfflinePublishQueueing(-1) 
        myMQTTClient.configureDrainingFrequency(2)  
        myMQTTClient.configureConnectDisconnectTimeout(10) 
        myMQTTClient.configureMQTTOperationTimeout(5)  

        myMQTTClient.connect()
   
        dictionary ={ 
            "event": event['devicePayload']['clickType'],
            "reportedTime": event['deviceEvent']['buttonClicked']['reportedTime']
        }

        # print(json.dumps(dictionary))

        myMQTTClient.publish(os.environ['Topic'], json.dumps(dictionary), 0)
        myMQTTClient.disconnect()

    return True
