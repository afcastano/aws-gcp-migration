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
	@docker build -t aws-terraform ./images/aws-terraform
	$(call dockerRun, terraform init)


run: ## Exec into the tools image. You could run aws and terraform commands from there
	$(call dockerRun, sh)

plan: ## Creates the plan to install WordPress in Aws
	$(call dockerRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))

apply: ## Executes the plan
	$(call dockerRun, terraform apply $(STATE_OUT) $(PLAN))

destroy: ## Cleans up the created resources
	$(call dockerRun, terraform destroy $(VAR_FILE) $(STATE))

.DEFAULT_GOAL := help

# HELPERS
define dockerRun
	@mkdir -p $(AWS_FOLDER)/out
	@docker run -it -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -v $(shell pwd)/$(AWS_FOLDER):/project \
			   aws-terraform:latest $(1)
endef
AWS_FOLDER=wp-aws-3tier
VAR_FILE=-var-file=variables.tfvars
STATE_FILE=out/terraform.tfstate
STATE=-state=$(STATE_FILE)
STATE_OUT=-state-out=$(STATE_FILE)
PLAN=out/terraform.plan
PLAN_OUT=-out=$(PLAN)
