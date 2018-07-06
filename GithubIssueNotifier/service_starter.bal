import ballerina/io;
import wso2/github4;
import ballerina/http;
import ballerina/time;
import ballerina/runtime;
import ballerina/config;

//Client endpoint for github service.
endpoint http:Client repositoryService {
    url: "http://localhost:9090"
};

//Client endpoint for sms service.
endpoint http:Client smsSender {
    url: "http://localhost:9095"
};

//Main entry point for the functionality.
function main(string... args) {
    //Run the loop forever
    while(true) {
        http:Response response = check repositoryService->get("/checkissues");
        //Check if response is json array or http:error.
        match response.getJsonPayload() {
            json res => {
                foreach issue in res {
                    var createdTime = stringToTime(issue.createdAt.toString());
                    //Check if the stringToTime function retruns an error or Time object
                    match createdTime {
                        time:Time timeCreated => {
                            //Get the current time.
                            time:Time currentTime = time:currentTime().toTimezone("Greenwich");
                            //Get the time difference between current time and created time
                            int timeDifference = currentTime.time - timeCreated.time;
                            //Check if difference is less than 15 seconds
                            if (timeDifference <= (1000*15)){
                                //Create the string text message that needs to be sent.
                                string messsage = "Hey " + config:getAsString("github.username") + ", your " +
                                    config:getAsString("github.repository") + " repository received a new issue.";
                                //Get the response from the sms sending client
                                var smsResponse = smsSender->post("/smslistener", messsage);
                                //Check if response is a Response or an error.
                                match smsResponse {
                                    http:Response smsRes => {
                                        io:println(smsRes);
                                    }
                                    error responseError => {
                                        io:println(responseError);
                                    }
                                }
                            }
                        }
                        error convError => {
                            io:println(convError);
                        }
                    }
                }
            }
            http:error er => {
                io:println(er);
            }
        }
        //Sleep the main thread for 10 seconds
        runtime:sleep(1000*10);
    }
}

//function which converts string time to Time format. Takes the string as the input and returns Time|error object
function stringToTime(string time) returns (time:Time|error){
    //Get the time without the timezone
    string timeWithoutZone = time.substring(0, time.length()-1);
    //Separate time and date
    string[] dateTime = timeWithoutZone.split("T");
    string[] dateTimeArray = dateTime[0].split("-");
    foreach i, timeStr in dateTime[1].split(":") {
        dateTimeArray[i+3] = timeStr;
    }
    //Convert the string value to integer values.
    int[] convertedArray =[];
    foreach i, str in dateTimeArray{
        match <int>str {
            int integer => {convertedArray[i] =integer;}
            error convError =>{return convError;}
        }
    }
    //Create the time object using convertedArray of integers.
    time:Time convertedTime = time:createTime(convertedArray[0], convertedArray[1], convertedArray[2],
        convertedArray[3], convertedArray[4], convertedArray[5], 0, "Greenwich");
    //return the convertedTime
    return convertedTime;
}
