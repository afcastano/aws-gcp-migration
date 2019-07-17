#!make
DIR=${CURDIR}/velostrata-config
include ${DIR}/out/velostrata.env

# based on https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

eula: ## Open browser to accept eula
	@open "https://$(velostrata_ip)"

configure_velostrata: ## Set up source and target clouds. Also creates a runbook ready to start.
	@echo "Populating templates..."
	$(call dockerRunTools, bash -c "source out/velostrata.env && envsubst<aws-credentials.tpl>out/aws-credentials.json")
	$(call dockerRunTools, bash -c "source out/velostrata.env && envsubst<aws-cloud-details.tpl>out/aws-cloud-details.json")
	$(call dockerRunTools, bash -c "source out/velostrata.env && envsubst<cloud-extensions.tpl>out/cloud-extensions.json")
	$(call dockerRunTools, bash -c "source out/velostrata.env && envsubst<generate-runbook.tpl>out/generate-runbook.json")
	
	@echo "Creating source cloud credentials"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@${DIR}/out/aws-credentials.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/credentials/aws
	@sleep 5
	
	@echo "Creating source cloud details"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/aws-cloud-details.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/details
	@sleep 5
	
	@echo "Creating cloud extensions"
	$(eval task := $(shell curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/cloud-extensions.json" https://$(velostrata_ip)/velostrata/api/v42/cloudextensions 2>/dev/null | jq -r '.value'))
	@echo "Checking task $(task)... this could take up to 5 mins..."
	@sleep 10

	@state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" && \
	progress="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.progress')" && \
	while [ "$$state" != "Succeeded" ] ; do \
		echo "Status: \"$$state\"... \"$$progress\"%, retrying in 30 seconds..." ; \
		sleep 30 ; \
		state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/t-2" 2>/dev/null | jq -r '.state')" ; \
		progress="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.progress')" ; \
	done; 
	
	@rm -f ${DIR}/out/runbook.csv
	@echo "Generating runbook..."
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/generate-runbook.json" -O -J  https://$(velostrata_ip)/auto/rest/runbooks
	@echo "Updating runbook..."
	@mkdir -p out
	@awk -F, -v OFS=, 'NR==2{$$1="1"; $$15="n1-standard-4"; $$20="true"}{print}' Velostrata_Runbook.csv > ${DIR}/out/runbook.csv
	@rm Velostrata_Runbook.csv
	@echo "Creating wave..."
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: text/csv" -X PUT --upload-file ${DIR}/out/runbook.csv https://$(velostrata_ip)/auto/rest/waves/w1
	@echo "Validating wave..."
	@curl -k --user apiuser:wpdemo1234 -X POST https://$(velostrata_ip)/auto/rest/waves/w1/validations

	@echo "DONE"

migrate: ## Run migration job
	@echo "Running cloud migration for wave w1"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST https://$(velostrata_ip)/auto/rest/waves/w1?type=RunInCloud

	@echo "\nThe migration could take up to 15 mins.... cheking status:"
	@sleep 30
	@state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/auto/rest/waves/w1" 2>/dev/null | jq -r '.lastJob.status')" && \
	while [ "$$state" == "Running" ] ; do \
		echo "Status: \"$$state\"..., retrying in 30 seconds..." ; \
		sleep 30; \
		state="$$(curl -k --user apiuser:wpdemo1234 "https://$(velostrata_ip)/auto/rest/waves/w1" 2>/dev/null | jq -r '.lastJob.status')" && \
		echo "$$state" ; \
	done;


define dockerRunTools
	@mkdir -p $(OUT_DIR)
	@docker run -it \
			    -v $(shell pwd)/velostrata-config:/project \
			    demo-tools:latest $(1)
endef

OUT_DIR=./out