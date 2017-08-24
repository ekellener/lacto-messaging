'use strict';

var api = require('../index.js');
var chai = require("chai");
var spies = require('chai-spies');
var config = require('config');

chai.use(spies);

const AWS = require('aws-sdk');
const claudiaConfig = require('../deploy/claudia/claudia.json');
const AWS_REGION = claudiaConfig.lambda.region;
const LAMBDA_NAME = claudiaConfig.lambda.name;

AWS.config.update({ region: AWS_REGION });

// Use a default message if one doesn't exist in the config file
var config = config.has('TestConfigNexmo') ? config.get('TestConfigNexmo') : {
    "messageId": "0B000000754B1F12",
    "text": "Need to configure default",
    "to": "2135551212",
    "keyword": "Need to configure default",
    "msisdn": "3105551212",
    "type": "text",
    "message-timestamp": "2017-08-18 01:51:15"
};



describe('Lambda integration tests', () => {
    var lambdaContextSpy;  
    var lambdaContext = {
        done: function () { }
    };
     

    beforeEach(() => {
        //dummy Spy
        lambdaContextSpy = chai.spy(lambdaContext, 'done');
        console.log(lambdaContextSpy);
    });

    it('Confirm that final Router request was completed', (done) => {
        api.proxyRouter({
            requestContext: {
                resourcePath: '/sms',
                httpMethod: 'GET',
                accountId: '123456790'
            },
            queryStringParameters: {
                "messageId": "0B000000754B1F12",
                "text": "Test text",
                "to": "12014935528",
                "keyword": "Test text",
                "msisdn": "18185129619",
                "type": "text",
                "message-timestamp": "2017-08-18 01:51:15"
            }
        }, lambdaContext)
            .then((response) => {
             chai.expect(lambdaContextSpy).to.have.been.called;
            }).then(done, done.fail);

    });
}); 