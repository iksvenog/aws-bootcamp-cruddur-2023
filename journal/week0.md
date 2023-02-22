# Week 0 — Billing and Architecture

## Required Homework/Tasks

### Installed AWS CLI in Gitpod Environment

I configured the gitpod.yml to install the AWS CLI upon the Gitpod environment launch, and set the CLI to use partial auto-prompt mode. The bash commands were referenced from: [AWS CLI Install Instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

The `.gitpod.yml` was updated to include the following task.

```sh
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```

### Created a New IAM User and Generated AWS Credentials

In the IAM User Console, I followed the steps below to create an Admin User:
- `Enable console access` for the user
- Create a new `Admin` Group and apply `AdministratorAccess`
- Create the user and go find and click into the user
- Click on `Security Credentials` and `Create Access Key`
- Choose AWS CLI Access
- Download the CSV with the credentials

### Set Env Vars

I configured the environment variables in Gitpod to securely hold the access information for my workspaces.
```
gp env AWS_ACCESS_KEY_ID=""
gp env AWS_SECRET_ACCESS_KEY=""
gp env AWS_DEFAULT_REGION=us-east-1
```

### Confirmed with the AWS CLI in Gitpod that the user was successfully added

```sh
aws sts get-caller-identity
```

The following output confirmed the configuration was successful
```json
{
    "UserId": "****************SCNO",
    "Account": "550506132895",
    "Arn": "arn:aws:iam::550506132895:user/igor.gonevski"
}
```

### Enabled Billing and Created Budget
I turned on Billing Alerts to recieve alerts by going to my Root Account [Billing Page](https://console.aws.amazon.com/billing/), and, under `Billing Preferences`, I chose the option to `Receive Billing Alerts`, and saved the preferences.

#### Created SNS Topic for the billing alarm
![SNS-Topic-Billing](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/BillingAlarmSNSTopic.PNG)
#### Created Billing Alarm after the SNS Topic
![Billing-Alarm-CloudWatch](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/BillingAlarmSNSTopic.PNG)

#### Created an AWS Budget
![Budget-Cost-Management](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/AWSBootcampBudget.PNG)

### Created Napkin Design of Conceptual Diagram for Cruddur
![My-Conceptual-Diagram](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/Resized_20230220_131952.jpeg)

### Created Logical Diagram of Cruddur Application in LucidChart
I learned how to recreate the logical diagram and practiced working with the features in LucidChart to create my own version [Logical-Chart-Recreation-Youtube-Video](https://www.youtube.com/watch?v=K6FDrI_tz0k&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv)

*The following link goes to the Logical Diagram I created in LucidChart: 

[Cruddur-Logical-Diagram](https://lucid.app/lucidchart/c03e69d5-0032-4158-9170-876199cdf275/edit?viewport_loc=-982%2C-466%2C3017%2C1390%2C0_0&invitationId=inv_43cafd77-e589-4213-8ff9-5fc70d1e4164)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Homework Challenges

### Created Health Service Alerts Using EventBridge
I create a service health alert with EventBridge and SNS to hookup the Health DashBoard, referencing the following link from the AWS Docs for both EventBridge and SNS Topic that needed to be created for the EventBridge Rule: [EventBridge-Service-Health-Alert-How-To](https://docs.aws.amazon.com/health/latest/ug/cloudwatch-events-health.html) and [SNS-Topic-How-To](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/US_SetupSNS.html)

#### Created SNS Service Health Alert
![SNS-Topic-Service-Health-Alert](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/HealthAlertSNSTopic.PNG)
#### Created EventBridge Health Alert
![EventBridge-Service-Health-Alert](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/EventBridgeHealthAlert.PNG)

### Used Well-Architected Framework Tool to Create Documentation
I watched Andrew's Well-Architected Framework video on Youtube for getting started with the Well-Architected Framework Tool [Well-Architected-Framework-Tool-Youtube-Video](https://www.youtube.com/watch?v=i-hOfAJb3cE&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=16). I looked over all of the questions using the tool interface and took the time to answer a question from each pillar. I attached a PDF of my work on the selection of questions generated from the Well-Architected Framework Tool in AWS: [Well-Architected-Framework-Tool-PDF](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/CruddurApplication_wellarchitected.pdf)

### Created an architectural diagram (to the best of my ability) of the CI/CD logical pipeline in Lucid Charts
I created a logical pipeline component in LucidChart after researching across a few AWS Blogs and encountered the following article [AWS-CI/CD-Reference-Documentation](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/automatically-build-ci-cd-pipelines-and-amazon-ecs-clusters-for-microservices-using-aws-cdk.html) from which I learned about CodePipeline and CodeBuild services in AWS that serve as tools for creating a hosted CI/CD workflow in AWS from which I created a logical pipeline diagram: [CI/CD-Diagram](https://lucid.app/lucidchart/d3595889-91ef-4146-82f2-0af51cadb76f/edit?viewport_loc=-677%2C-408%2C2843%2C1309%2C0_0&invitationId=inv_326f8055-2bc5-4781-b50b-a7e4f9f799a2)

```
The workflow above goes through the following steps:
1. Developers submit commits / updates to the Github repository / CodeCommit repository in AWS.
2. CodeBuild is the AWS service responsible for pushing the updated Docker image to the ECR repository in AWS.
3. The resulting registered image gets deployed to an ECS Cluster into the containerized workload as part of Cruddur's application architecture.
4. Testing is performed using a non-production URL within a testing environment leveraging a test case of the Cruddur architecture.
5. For a production workload, the project / release manager is involved in manually approving the committed change to the production workload.
6. The committed change that gets signed off is then deployed for use in the production workload environment after getting registered in the ECR production namespace.
7. The release manager approves the production deployment.
8. Production users then access the feature by using a production URL.
9. This cycle continues within a continously developing CI/CD process for the lifecycle of the Cruddur project.
```

### Researched service limits of specific services (EC2 Auto-Scaling) and requested a Service Limit Increase with AWS ServiceQuota
Service Limits restrict the capacity of resources that can be used at any given time; this prevents a larger-scale project from deploying if certain services are already reaching their current capacity. A Service Quota request would resolve this issue by requesting service limit increases. For example, using EC2 Auto-Scaling as an example, this service is critical for upscaling compute resources for any given workload requiring high performance. If a service limit is encountered for the horizontal scaling of compute resources, this would cap how much the current workload is able to process request and any given computations, which would prevent the workload from handling larger amounts of requests from incrased user activity and upscaled production hours. As a result, I reviewed some existing service limits for EC2 Auto-Scaling, and found the following service limits using the Service Quota Tool in AWS.
![List-of-Researched-Service-Limits-for-EC2-AutoScaling](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/Researched-Service-Limits-for-EC2-AutoScaling.PNG)
As part of practice, I requested a service limit increase for the number of auto-scaling configurations per region, which was currently limited to only 200. This could be pose an issue when a compute workload needs to be massively upscaled within a given Region, for which a service limit increase would help to mitigate this issue.
![ServiceLimit-Increase-Requested-for-EC2AutoScaling-Launch-Configuration-Amount-per-Region](https://github.com/iksvenog/aws-bootcamp-cruddur-2023/blob/main/_docs/assets/week0/ServiceQuotaIncreaseforEC2AutoScaleConfigurations.PNG)
