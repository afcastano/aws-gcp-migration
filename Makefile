# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@echo "\033[31mInstall WordPress 3-tier application in Aws and migrate it to GCP"
	@echo ""
	@echo "\033[0mTargets:"
	@echo "----------------"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Main targets

init: ## Creates the tools docker image and inits terraform. (Only needed on a fresh repo)
	@docker build -t demo-tools ./images/demo-tools
	$(call awsRun, terraform init)
	$(call gcpRun, terraform init)

plan: plan-gcp plan-aws ## Creates the plan for aws and gcp

apply: apply-gcp apply-aws ## Applies the plan for aws and gcp

destroy: destroy-gcp destroy-aws ## Destroy the resources in aws and gcp

######################################################################

plan-aws: ## Creates the plan to install WordPress in Aws
	$(call awsRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))

apply-aws: ## Executes the aws plan
	$(call awsRun, terraform apply $(STATE_OUT) $(PLAN))

destroy-aws: ## Cleans up the created resources in aws
	$(call awsRun, terraform destroy $(VAR_FILE) $(STATE) -auto-approve)

plan-gcp: ## Creates the plan to set up the network in GCP
	$(call gcpRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))	

apply-gcp: ## Executes the gcp plan
	$(call gcpRun, terraform apply $(STATE_OUT) $(PLAN))	

destroy-gcp: ## Cleans up the created resources in gcp
	$(call gcpRun, terraform destroy $(VAR_FILE) $(STATE) -auto-approve)

########################################################################

run-aws: ## Exec into the aws tools image. You could run aws and terraform commands from there
	$(call awsRun, sh)

run-gcp: ## Exec into the gcp tools image. You could run gcp and terraform commands from there
	$(call awsRun, sh)

.DEFAULT_GOAL := help

# HELPERS
define awsRun
	$(call dockerRun,$(1),$(AWS_FOLDER))
endef

define gcpRun
	$(call dockerRun,$(1),$(GCP_FOLDER))
endef

define dockerRun
	@mkdir -p $(2)/out
	@docker run -it -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -v ${GCLOUD_KEYFILE_JSON}:/root/.gcp/terraform_sa.json \
			   -v $(shell pwd)/$(2):/project \
			   demo-tools:latest $(1)
endef
AWS_FOLDER=aws
GCP_FOLDER=gcp
VAR_FILE=-var-file=variables.tfvars
STATE_FILE=out/terraform.tfstate
STATE=-state=$(STATE_FILE)
STATE_OUT=-state-out=$(STATE_FILE)
PLAN=out/terraform.plan
PLAN_OUT=-out=$(PLAN)
