This is a simple node project that is used to add SMS subscribers to an subscription. 

It has been implemented with :

 - AWS Lambda 
 - AWS SNS (SMS interface) 
 - ClaudiaJS for build mgmt of the Lambda function 
 - ClaudiaJS api-builder for AWS Gateway API provisioning an linking to the Lambda function.  
 - AWS CLI in a couple of bash scripts (cleanup roles).

The URL defaults to responding to a GET /sms and uses the [Nexmo.com API](https://www.nexmo.com/).

The interaction with Nexmo was based off of this video. The primary change was using claudiajs api-builder instead of the manual api gateway process.
https://www.nexmo.com/blog/2016/05/31/building-sms-google-sheets-application-aws-lambda-dr/

In order to run :
 1. Ensure you have an AWS account, and a Nexmo virtual phone number. 
 2. Configure the **AWS_DEFAULT_PROFILE, AWS_DEFAULT_REGION** and **NODE_ENV**  environment  variables. 
 3. Run `npm run claudia-create` to install the lambda function.  It will create an output that looks like this:
>    *Running profile: default
    lacto-messaging-executor
    lacto-messaging
    ***  Attempting to delete existing roles,policies, and aliases..(may see errors).
    All done...
    validating package
    saving configuration
    {
      "lambda": {
        "role": "lacto-messaging-executor",
        "name": "lacto-messaging",
        "region": "us-east-1"
      },
      "api": {
        "id": "n434c7y212",
        "module": "index",
        "url": "**https://n4h4c7y212.execute-api.us-east-1.amazonaws.com/prod**"
      },
      "archive": "/var/folders/q4/r126cqf926b_ccsvby431vgc0000gn/T/1cef9d1c-f1c6-49b6-bd74-d69b6db20d5c.zip"
    }*

 4. Copy the URL at the api.url **(bolded above)** , and paste it in the  Nexmo API "Webhook URL" for the phone number you want to use
 5. That's it.. send a text to your Nexmo phone number, and it  should add you and send a welcome message.

Other scripts available  in the /bin folder

    /bin/createapi.sh 

*(Deprecated and no longer needed now that api-builder is implemented)*


    /bin/cleanclaudia.sh 

When the lambda function needs to be created, in order to ensure there aren't any left over privileges, its cycles through the IAM stuff to get rid of any potential conflicts.




> Written with [StackEdit](https://stackedit.io/).
