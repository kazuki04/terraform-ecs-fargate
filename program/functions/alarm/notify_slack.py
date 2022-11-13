#!/usr/bin/python3.9

import urllib3
import json
import os
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

http = urllib3.PoolManager()

def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES')
    logger.info(os.environ)
    logger.info('## EVENT')
    logger.info(event)

    url = os.environ["SLACK_WEBHOOK_URL"]
    msg = {
        "channel": os.environ['CHANNEL_NAME'],
        "username": os.environ['USERNAME'],
        "text": event['Records'][0]['Sns']['Message'],
        "icon_emoji": ""
    }

    encoded_msg = json.dumps(msg).encode('utf-8')
    resp = http.request('POST', url, body=encoded_msg)

    logger.info('## RESPONSE')
    logger.info(resp)

    print({
        "message": event['Records'][0]['Sns']['Message'],
        "status_code": resp.status,
        "response": resp.data
    })
