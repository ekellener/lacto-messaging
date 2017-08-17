'use strict';

//# Uses Nexmo's API
//# Referenced: https://www.nexmo.com/blog/2016/05/31/building-sms-google-sheets-application-aws-lambda-dr/


// Configuring the AWS SDK
var AWS = require('aws-sdk');
AWS.config.update({ region: 'us-east-1' });

console.log('Loading function');


exports.handler = (event, context, callback) => {

    console.log('Received event:', JSON.stringify(event, null, 2));
    var snsTopicArn, params;
    var sns = new AWS.SNS();
    sns.listTopics({}, function (err, data) {
        if (err) {
            console.log(err, err.stack); // an error occurred
        }
        else {
            // successful response
            snsTopicArn = JSON.stringify(data.Topics[0].TopicArn);
            snsTopicArn = snsTopicArn.replace(/['"]+/g, '');
            console.log(snsTopicArn);

            params = {
                Protocol: 'sms',
                TopicArn: snsTopicArn,
                Endpoint: event.msisdn
            };

            // Add sender's phone to subscriber
            sns.subscribe(params, function (err, data) {
                if (err) console.log(err, err.stack); // an error occurred
                else {
                    console.log(data);           // successful response
                    // Send an SMS back to the subscriber to let them know they've been added
                    sns.publish({
                        Message: "Welcome to the LACTO Forum SMS group. To Opt-out, just reply to using the word STOP.",
                        PhoneNumber: event.msisdn
                    }, function (err, data) {
                        if (err) {
                            console.log(err.stack);
                        }
                    });
                }
            })
        }
    });

    callback(null, event.msidn);
};
