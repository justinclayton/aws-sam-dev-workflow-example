REGION             = us-west-2
STACK_NAME         = example-vote
DEPLOY_BUCKET_NAME = $(STACK_NAME)-deploy-artifacts

include config ## use to override above variables

run-local: validate start-dynamodb start-api

validate:
	sam validate

clean:
	rm -f shared-local-instance.db serverless-output.yaml

clean-all: clean undeploy

dev-setup: start-dynamodb create-table stop-dynamodb

deploy-setup: create-deploy-bucket

package: clean
	sam package \
		--template-file template.yml \
		--output-template-file serverless-output.yaml \
		--region $(REGION) \
		--s3-bucket $(DEPLOY_BUCKET_NAME)

deploy:
	sam deploy \
		--template-file serverless-output.yaml \
		--capabilities CAPABILITY_IAM \
		--region $(REGION) \
		--stack-name $(STACK_NAME)

undeploy:
	aws cloudformation delete-stack --stack-name $(STACK_NAME)

create-deploy-bucket:
	aws s3 mb s3://$(DEPLOY_BUCKET_NAME) --region $(REGION)

create-table:
	aws dynamodb create-table \
		--table-name "local-test-table" \
		--attribute-definitions "AttributeName=id,AttributeType=S" \
		--key-schema "AttributeName=id,KeyType=HASH" \
		--provisioned-throughput "ReadCapacityUnits=1,WriteCapacityUnits=1" \
		--endpoint-url "http://localhost:8000"

start-api:
	sam local start-api

start-dynamodb: stop-dynamodb
	docker run -d --name dynamodb -v ${PWD}:/dynamodb_local_db -p 8000:8000 cnadiminti/dynamodb-local:latest

stop-dynamodb:
	docker stop dynamodb; true
	docker rm dynamodb; true

local-test:
	curl -X GET http://localhost:3000/hello
	curl -X GET http://localhost:3000/vote
	curl -X POST http://localhost:3000/vote -d '{"vote": "spaces"}'
	curl -X POST http://localhost:3000/vote -d '{"vote": "spaces"}'
	curl -X POST http://localhost:3000/vote -d '{"vote": "tabs"}'

remote-test:
	curl -X GET `make get-api-url`/hello
	curl -X GET `make get-api-url`/vote
	curl -X POST `make get-api-url`/vote -d '{"vote": "spaces"}'
	curl -X POST `make get-api-url`/vote -d '{"vote": "spaces"}'
	curl -X POST `make get-api-url`/vote -d '{"vote": "tabs"}'

get-api-url:
	@echo https://`aws cloudformation describe-stack-resource --stack-name $(STACK_NAME) --logical-resource-id ServerlessRestApi | jq -r '.StackResourceDetail.PhysicalResourceId'`.execute-api.$(REGION).amazonaws.com/Prod/
