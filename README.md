# AWS SAM Development Workflow Example

This repo should help you get started authoring, testing, and deploying your own serverless web API using AWS Lambda, SAM, and DynamoDB, whether locally or in your own AWS account.

## What's here:
* 3 AWS Lambda functions:
  * Hello World
  * POST Your Vote
  * Vote Results
* An AWS SAM Template, which wires them up to:
  * DynamoDB
  * IAM
  * API Gateway
* A Makefile to stand it all up:
  * Setup your local dev environment
  * Package and deploy to your AWS account

## Usage

### Before Starting
* Ensure that `make` is installed.
* Ensure that Docker is installed.
* Install the AWS CLI: `pip install awscli`, etc.
* Install the AWS SAM CLI: `npm install -g aws-sam-local`, etc.
* Edit the provided `config` file to override `STACK_NAME` and other relevant values.

### Local development

#### First time setup
```
$ make dev-setup # creates local dynamodb table
```

#### Development workflow
```
$ make # starts local dynamodb and local api gateway in the foreground
```

In another terminal, run:

```
$ make local-test # curls local endpoints to trigger your lambdas
```

Test your code, edit your functions, hit save, and test them again.

### Deployment to AWS

#### First time setup
```
$ make deploy-setup # creates your s3 bucket to store SAM packages
```

#### Deployment workflow
When you're ready to deploy your code to AWS:

```
$ make package # creates and pushes your SAM package
$ make deploy # deploys your SAM package to your AWS account
$ make remote-test # curls your newly-created remote API endpoints
```

### Tearing it down

```
$ make clean-all # destroys all resources, local and remote
```
