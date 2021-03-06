'use strict';

var Promise = require('bluebird');
var config = require('config');

//# Uses Nexmo's API
//# Referenced: https://www.nexmo.com/blog/2016/05/31/building-sms-google-sheets-application-aws-lambda-dr/
//# TODO : Add better error handling, and configify the Welcome Message

// Use a default message if one doesn't exist in the config file
var configWelcomeMessage = config.has('WelcomeMessage') ? config.get('WelcomeMessage') : "Hello.";

var AWS = require('aws-sdk');
var APIBuilder = require('claudia-api-builder');

// Configuring the AWS SDK
AWS.config.setPromisesDependency(require('bluebird'));
console.log('Loading function');


//const acct = AWS.config.acc
var apiSMS = new APIBuilder();
module.exports = apiSMS;


// Register /sms GET for Nexmo API
apiSMS.get('/sms', function (event) {
    console.log('Received event:', JSON.stringify(event, null, 2));
    var snsTopicArn, accountId, userArn, userArnAry, params, res, data;
    var sts = new AWS.STS();
    var sns = new AWS.SNS();
    var region = AWS.config.region;
    return sts.getCallerIdentity({}).promise()
        .then(function (dataUser) {
            accountId = JSON.stringify(dataUser.Account).replace(/['"]+/g, '');
            snsTopicArn = "arn:aws:sns:"+region+":"+accountId+":"+config.SNSTopicName;
            params = {
                Protocol: 'sms',
                TopicArn: snsTopicArn,
                Endpoint: event.queryString.msisdn
            };
        })
        .then(function () {
 //           console.log(params);
            return sns.subscribe(params).promise();
        })
        .then(sns.publish({ Message: configWelcomeMessage, PhoneNumber: event.queryString.msisdn }).promise())
        .catch(function (e) {
            console.error(e.message);
            console.error(e.stack);
        });
});



