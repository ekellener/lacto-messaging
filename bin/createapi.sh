#!/bin/bash

#Default variable
apiName="LambdaLACTO"
lambdaFunction="lacto-messaging"
topicName="member"
region=$AWS_DEFAULT_REGION


# Gather current User's full ARN
echo "Extracting ARN and Account ID"
Arn=`aws sts get-caller-identity --query Arn |  sed 's/^"\(.*\)"$/\1/'`

# Gather user's account id
awsAccount=`aws sts get-caller-identity --query Account |  sed 's/^"\(.*\)"$/\1/'`
functionArn=`aws lambda get-function --function-name $lambdaFunction --query Configuration.FunctionArn --output text` 
getIdcmd="aws apigateway get-rest-apis --query 'items[?name==\`$apiName\`].id' --output text"
getId=`eval $getIdcmd`


 #Create SNS subscription if one doesn't already exist
snsArn=$(aws sns list-topics --profile lacto --region $region  --output text --query 'Topics[0]' | grep $topicName)
if [ -z "$snsArn" ];then
echo "No existing Topics. Creating one"
snsArn=$(aws sns create-topic --name $topicName --output text --query TopicArn)
fi

#Add permissions for Lambda to modify SNS
#echo "Adding permissions for lambda to access SNS"
#aws sns add-permission --region $region --topic-arn $snsArn --label lambda-access --aws-account-id $awsAccount --action-name Subscribe Publish 

#Initialize by deleting API if it exists
if [ -z "$getId" ];then
echo "No Lambda to initialize"
else
echo "Deleting API"
aws apigateway delete-rest-api --rest-api-id $getId
fi

# Create and assign Baseline Rest api
restApiId=`aws apigateway import-rest-api --body 'file://./deploy/apiconf/api-export.json' --query 'id' --output text`
echo "Created api ID:  $restApiId .. Waiting to propagate"
sleep 6
# Now need to patch to use the right name
#Updating Name - Kind of ugly approach.
aws apigateway update-rest-api --rest-api-id $restApiId --patch-operations op=replace,path=/name,value=$apiName


smsResourceId=`aws apigateway get-resources --rest-api-id $restApiId --query 'items[1].id' --output text`
echo "Created resource ID: $smsResourceId.. Waiting to for propagation"
sleep 5 
echo "Adding Method to resource:$smsResourceId "
aws apigateway put-method  --rest-api-id $restApiId --resource-id $smsResourceId  --cli-input-json 'file://./deploy/apiconf/method.json' 

sleep 3
# Update uri for method
uri="arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/$functionArn/invocations"
echo "Updating: $uri"
#aws apigateway update-method --rest-api-id $restApiId --resource-id $smsResourceId --http-method GET  --patch-operations op=replace,path=/uri,value=$uri
echo "Waiting for propagation"
sleep 7 

echo "Adding Integrations to API"
aws apigateway put-integration --type AWS  --rest-api-id $restApiId --resource-id $smsResourceId --http-method ANY --uri "arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/$functionArn/invocations" --cli-input-json 'file://./deploy/apiconf/integration.json'

echo "Adding Default method Response to API"
aws apigateway put-method-response --rest-api-id $restApiId --resource-id $smsResourceId --http-method ANY --status-code 200   --response-models "{}" 

echo "Adding Default Integration Response to API"
aws apigateway put-integration-response --rest-api-id $restApiId --resource-id $smsResourceId --http-method ANY --status-code 200 --selection-pattern "" --response-templates '{"application/json": ""}' 

echo "Adding permission to execute lambda from API"
aws lambda add-permission --function  $functionArn --source-arn "arn:aws:execute-api:$region:$awsAccount:$restApiId/*/*/sms" --principal apigateway.amazonaws.com --action lambda:InvokeFunction --statement-id $(uuidgen)

echo "Deploying API to prod."
sleep 5
aws apigateway create-deployment --rest-api-id $restApiId --stage-name prod
echo "Deploy. Don't forgot to update Nexmo's sms/phone webhook URL with: https://$restApiId.execute-api.us-east-1.amazonaws.com/prod/sms"
