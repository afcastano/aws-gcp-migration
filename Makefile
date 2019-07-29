# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
.SILENT: help init plan apply eula configure_velostrata velostrata_migrate destroy update_host

help: ## This help
	echo "\033[31mInstall WordPress 3-tier application in Aws and migrate it to GCP"
	echo ""
	echo "\033[0mTargets:"
	echo "----------------"
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Main targets

deploy: ## Deploys the WP application in AWS and sets up the VPN
	docker build -t demo-tools ./images/demo-tools
	$(call terraform, init)
	$(call terraform, plan)
	$(call terraform, apply)
	mkdir -p velostrata-config/out
	cp terraform/out/velostrata.env velostrata-config/out/velostrata.env

eula: ## Open browser to accept velostrata eula
	$(call velostrata, eula)

velostrata_migrate: ## Run migration job
	echo configuring velostrata...
	$(call velostrata, configure)
	sleep 30
	echo starting migration...
	$(call velostrata, migrate)
	echo updating instance group...
	sleep 30
	$(call velostrata, update_instance_group)
	echo done

destroy: ## Cleans up the created resources in aws and gcp
	$(call velostrata, clean)
	$(call terraform, destroy)

update_host: ## Updates local etc/hosts with WP ip. Requires wpip env variable to be set.
	$(call terraform, update_host)

open_demo:
	$(call terraform, open_demo)


.DEFAULT_GOAL := help

define terraform
	cd terraform && $(MAKE) $1
endef

define velostrata
	cd velostrata-config && $(MAKE) $1
endef

export GCP_PROJECT := $(shell cat terraform/variables.tfvars | grep gcp_projectId | cut -d "=" -f2 | sed "s/\"//g")
