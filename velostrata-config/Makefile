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
	@open "https://35.244.74.70"

clouds: ## Set up source and target clouds
	@echo "Creating source cloud credentials"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@aws-credentials.json" https://35.244.74.70/velostrata/api/v42/cloud/credentials/aws
	@sleep 2
	
	@echo "Creating source cloud details"
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@aws-cloud-details.json" https://35.244.74.70/velostrata/api/v42/cloud/details
	@sleep 2
	
	@echo "Creating cloud extensions"
	$(eval task := $(shell curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@cloud-extensions.json" https://35.244.74.70/velostrata/api/v42/cloudextensions 2>/dev/null | jq -r '.value'))
	@echo "Checking task $(task)"
	@sleep 2

	@state="$$(curl -k --user apiuser:wpdemo1234 "https://35.244.74.70/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" && \
	@while [ "$$state" != "Succeeded" ] ; do \
		echo "Message: \"$$state\", retrying in 30 seconds..." ; \
		sleep 30 ; \
		state="$$(curl -k --user apiuser:wpdemo1234 "https://35.244.74.70/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" ; \
		echo "$$state" ; \
	done; 
	@echo "done"

runbook:
	@rm -f out/runbook.csv
	@echo "Generating runbook..."
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@generate-runbook.json" -O -J  https://35.244.74.70/auto/rest/runbooks
	@echo "Updating runbook..."
	@mkdir -p out
	@awk -F, -v OFS=, 'NR==2{$$1="1"; $$15="n1-standard-4"; $$20="true"}{print}' Velostrata_Runbook.csv > out/runbook.csv
	@rm Velostrata_Runbook.csv
	@curl -k --user apiuser:wpdemo1234 -H "Content-Type: text/csv" -X PUT -d "@out/runbook.csv" https://35.201.21.241/auto/rest/waves/w1