# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Main targets
run: ## Exec into the aws-terraform image
	$(call dockerRun, sh)

init: ## Run terraform init. (Only needed on a fresh repo)
	$(call dockerRun, terraform init)

plan: ## Create the terraform plan using the aws-terraform image
	$(call dockerRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))

apply: ## Apply the terraform plan using the aws-terraform image. Should be run after make plan
	$(call dockerRun, terraform apply $(STATE_OUT) $(PLAN))

destroy: ## Destroy the resources created with terraform
	$(call dockerRun, terraform destroy $(VAR_FILE) $(STATE))

.DEFAULT_GOAL := help

# HELPERS
define dockerRun
	@mkdir -p out
	@docker run -it -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -v $(shell pwd):/project \
			   aws-terraform:latest $(1)
endef

VAR_FILE=-var-file=variables.tfvars
STATE_FILE=out/terraform.tfstate
STATE=-state=$(STATE_FILE)
STATE_OUT=-state-out=$(STATE_FILE)
PLAN=out/terraform.plan
PLAN_OUT=-out=$(PLAN)
