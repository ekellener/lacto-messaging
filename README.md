This is a simple project that is used add SMS subscribers to an SMS subscription. 

It has been implemented with :
- AWS Lambda
- AWS SNS (SMS interface)
- AWS Gateway API to route external URLs to the Lambda Function.
- ClaudiaJS for build mgmt of the Lambda function
- AWS CLI in a couple of bash scripts.

The URL defaults to responding to a GET /sms and uses the Nexmo.com API.


In order to run
- Ensure you have an AWS account, and a Nexmo virtual phone number.
- Configure the AWS_DEFAULT_PROFILE and AWS_DEFAULT_REGION asn env. variables.
- Run npm run claudia-create to install the lambda function.
- Run ./bin/createapi.sh to create an Gateway API to the lambda function
- Copy the URL at the final line of the above
script, and paste it in the Nexmo API for the phone number you want to use.

The build uses ClaudiaJS to create, update and destroy the lambda function.

Other scripts available  in the /bin folder

createapi.sh 
- Manually run after the lambda function has been created. 

cleanclaudia.sh 
- When the lambda function needs to be created, in order to ensure there aren't any left over privileges, its cycles through the IAM stuff to get rid of any potential conflicts.