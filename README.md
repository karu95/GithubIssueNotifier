# GithubIssueNotifier

# Project Idea:
Primary objective of this project is to notify github repository owner with an SMS when an issue is created for the project. I will be using twilio API and github API for the process. Ballerina language will be used to integrate two services.

# Flow of the project:

    1. GithubNotifier request latest created issues from GithubConnector.
    2. GithubConnector talks to github API and get latest issues.
    3. GithubNotifier checks if any issue which is not notified.
    4. If any new issue available GithubNotifier sends an SMS to repository owner through twilio API.
    5. Above process will be carried out for every 10 seconds.

# How to use:
1. Download the github repository.
2. Rename the sample_ballerina.conf file to ballerina.conf
3. Set the parameters of the ballerina.conf as defined in the ballerina.conf
    *# Note - xAuthKey is not an essential parameter. You can keep it empty.
4. Then run the command following command in project directory.

          ballerina run GithubIssueNotifier
5. Now the GithubIssueNotifier should be up and running.
