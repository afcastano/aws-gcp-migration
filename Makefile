# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
.SILENT: help init plan apply eula configure_velostrata velostrata_migrate destroy

help: ## This help
	echo "\033[31mInstall WordPress 3-tier application in Aws and migrate it to GCP"
	echo ""
	echo "\033[0mTargets:"
	echo "----------------"
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Main targets

init: ## Creates the tools docker image and inits terraform. (Only needed on a fresh repo)
	docker build -t demo-tools ./images/demo-tools
	$(call terraform, init)

plan: ## Creates the plan to install WordPress in Aws, set up networks in both aws and gcp
	$(call terraform, plan)

apply: ## Executes the terraform plan and copy environment to velostrata
	$(call terraform, apply)
	mkdir -p velostrata-config/out
	cp terraform/out/velostrata.env velostrata-config/out/velostrata.env

eula: ## Open browser to accept velostrata eula
	$(call velostrata, eula)

configure_velostrata: ## Set up source and target clouds. Also creates a runbook ready to start.
	$(call velostrata, configure)

velostrata_migrate: ## Run migration job
	$(call velostrata, migrate)

destroy: ## Cleans up the created resources in aws and gcp
	$(call velostrata, clean)
	$(call terraform, destroy)

exec_velostrata: ## Execs into the velostrata builder image to run custom commands
	$(call velostrata, exec)

exec_terraform: ## Execs into the terraform builder image to run custom commands
	$(call terraform, exec)

update_host: ## Updates local etc/hosts with WP ip. Requires wpip env variable to be set.
	$(call terraform, update_host)
		

.DEFAULT_GOAL := help

define terraform
	cd terraform && $(MAKE) $1
endef

define velostrata
	cd velostrata-config && $(MAKE) $1
endef

export GCP_PROJECT := $(shell cat terraform/variables.tfvars | grep gcp_projectId | cut -d "=" -f2 | sed "s/\"//g")
