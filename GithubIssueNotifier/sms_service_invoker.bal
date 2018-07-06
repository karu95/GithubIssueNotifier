import ballerina/http;
import ballerina/log;
import wso2/twilio;
import ballerina/config;
import ballerina/io;

//Endpoint for twilio API
endpoint twilio:Client twilioEP  {
    accountSId: config:getAsString("twilio.accountSID"),
    authToken: config:getAsString("twilio.authToken"),
    xAuthyKey: config:getAsString("twilio.xAuthKey")
};

//SMS service listener endpoint. Set for port:9095
endpoint http:Listener smsListener{
    port: 9095
};

//Path configuration of the service.
@http:ServiceConfig {
    basePath: "/smslistener"
}

//This service invokes and sends a SMS through the twilio client
service<http:Service> issueNotifier bind smsListener {

    //Resource configuration of issueSender resource.
    //All post requests from smslistener/ will be handled by this resource
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/"
    }

    //This resource retrieves the SMS message data from the request and send it to the twilio API through twilio endpoint
    issueSender(endpoint caller, http:Request req) {
        //Retrives the message from the request.
        string message = check req.getTextPayload();
        //Get the response of the message sending request from the twilio API.
        var details = twilioEP->sendSms(config:getAsString("sms.sender"), config:getAsString("sms.receiver"), message);
        //Check if the response is a error or a success.
        match details {
            twilio:SmsResponse smsResponse => io:println(smsResponse);
            twilio:TwilioError twilioError => io:println(twilioError);
        }
    }
}
