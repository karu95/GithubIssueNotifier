import ballerina/http;
import ballerina/log;
import ballerina/config;
import wso2/github4;
import ballerina/io;

//Configuration of the github endpoint
endpoint github4:Client githubEP {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("github.GITHUB_TOKEN")
        }
    }
};

//Github Service Listener. Set for port : 9090
endpoint http:Listener githubListener {
    port: 9090
};

//Configuration of the path to the service
@http:ServiceConfig {
    basePath: "/checkissues"
}

//Service which runs when a /checkissue request is received
service<http:Service> issueRetriever bind githubListener {

    //Resource configuration of retrieveIssue resoure. Invokes when get request received.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }

    //This resource gets the set of last 10 issues of the given repository and send to the client.
    retrieveIssue(endpoint caller, http:Request request) {
        //Create the response for the client
        http:Response response = new;
        //Create the repository
        github4:Repository repo = {owner:{login:config:getAsString("github.username")}, name:config:getAsString("github.repository")};
        //
        var issues = githubEP->getIssueList(repo, github4:STATE_OPEN, 10);
        //Check if returned value is a issueList or GitClientError
        match issues {
            github4:IssueList issueList => {
                //Create the json array of issues
                json issueArray = [];
                foreach i, issue in issueList.getAllIssues() {
                    var jsonIssue = check <json>issue;
                    issueArray[i] = jsonIssue;
                }
                //Set the issueArray as response payload.
                response.setJsonPayload(issueArray);
            }
            github4:GitClientError gitError => {
                io:println(gitError.message);
                //Set the error message as response.
                response.setTextPayload(gitError.message);
            }
        }
        //Send the response to the client.
        _=caller->respond(response);
    }
}
