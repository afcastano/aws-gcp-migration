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
	$(call dockerRun,terraform init)

plan: ## Creates the plan to install WordPress in Aws, set up networks in both aws and gcp
	$(call dockerRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))

apply: ## Executes the aws plan
	$(call dockerRun, terraform apply $(STATE_OUT) $(PLAN))

destroy: ## Cleans up the created resources in aws
	$(call dockerRun, terraform destroy $(VAR_FILE) $(STATE) -auto-approve)

.DEFAULT_GOAL := help

define dockerRun
	@mkdir -p terraform/$(OUT_DIR)
	@docker run -it -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -v ${GCLOUD_KEYFILE_JSON}:/root/.gcp/terraform_sa.json \
			   -v $(shell pwd)/terraform:/project \
			   demo-tools:latest $(1)
endef
OUT_DIR=./out
VAR_FILE=-var-file=variables.tfvars
STATE_FILE=$(OUT_DIR)/terraform.tfstate
STATE=-state=$(STATE_FILE)
STATE_OUT=-state-out=$(STATE_FILE)
PLAN=$(OUT_DIR)/terraform.plan
PLAN_OUT=-out=$(PLAN)