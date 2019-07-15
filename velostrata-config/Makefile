#!make
include out/velostrata.env

# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@echo "\033[31mSet up velostrata and waves"
	@echo ""
	@echo "\033[0mTargets:"
	@echo "----------------"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

eula: ## Open browser to accept eula
	@open "https://$(velostrata_ip)"

clouds: ## Set up source and target clouds
	@echo "Populating templates..."
	$(call dockerRun, bash -c "source out/velostrata.env && envsubst<aws-credentials.tpl>out/aws-credentials.json")
	$(call dockerRun, bash -c "source out/velostrata.env && envsubst<aws-cloud-details.tpl>out/aws-cloud-details.json")
	$(call dockerRun, bash -c "source out/velostrata.env && envsubst<cloud-extensions.tpl>out/cloud-extensions.json")
	@echo "Creating source cloud credentials"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@out/aws-credentials.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/credentials/aws
	@sleep 10
	
	@echo "Creating source cloud details"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@out/aws-cloud-details.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/details
	@sleep 10
	
	@echo "Creating cloud extensions"
	$(eval task := $(shell curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@out/cloud-extensions.json" https://$(velostrata_ip)/velostrata/api/v42/cloudextensions 2>/dev/null | jq -r '.value'))
	@echo "Checking task $(task)"
	@sleep 10

	@state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" && \
	while [ "$$state" != "Succeeded" ] ; do \
		echo "Message: \"$$state\", retrying in 30 seconds..." ; \
		sleep 30 ; \
		state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" ; \
		echo "$$state" ; \
	done; 
	@echo "done"

runbook:
	$(call dockerRun, bash -c "source out/velostrata.env && envsubst<generate-runbook.tpl>out/generate-runbook.json")
	@rm -f out/runbook.csv
	@echo "Generating runbook..."
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@out/generate-runbook.json" -O -J  https://$(velostrata_ip)/auto/rest/runbooks
	@echo "Updating runbook..."
	@mkdir -p out
	@awk -F, -v OFS=, 'NR==2{$$1="1"; $$15="n1-standard-4"; $$20="true"}{print}' Velostrata_Runbook.csv > out/runbook.csv
	@rm Velostrata_Runbook.csv
	@echo "Creating wave..."
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: text/csv" -X PUT --upload-file out/runbook.csv https://$(velostrata_ip)/auto/rest/waves/w1
	@echo "Validating wave..."
	@curl -k --user apiuser:wpdemo1234 -X POST https://$(velostrata_ip)/auto/rest/waves/w1/validations

exec: ## Execs into the builder image to run custom commands
	$(call dockerRun, bash)

define dockerRun
	@mkdir -p $(OUT_DIR)
	@docker run -it \
			    -v $(shell pwd):/project \
			    demo-tools:latest $(1)
endef

OUT_DIR=./out