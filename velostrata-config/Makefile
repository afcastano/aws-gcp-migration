.SILENT: clean exec eula configure migrate update_instance_group

-include ${CURDIR}/out/velostrata.env

DIR=${CURDIR}
OUT_DIR=./out

eula: ## Open browser to accept velostrata eula
	open "https://$(velostrata_ip)"

configure: ## Set up source and target clouds. Also creates a runbook ready to start.
	echo "Please be sure you accepted the eula. Run \"make eula\" to accept."
	$(call dockerRun, bash -c "source out/velostrata.env \
		&& envsubst<templates/aws-credentials.json.tpl>out/aws-credentials.json \
		&& envsubst<templates/aws-cloud-details.json.tpl>out/aws-cloud-details.json \
		&& envsubst<templates/cloud-extensions.json.tpl>out/cloud-extensions.json \
		&& envsubst<templates/generate-runbook.json.tpl>out/generate-runbook.json")
	
	echo "Creating source cloud credentials"
	curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X PUT -d "@${DIR}/out/aws-credentials.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/credentials/aws > /dev/null
	sleep 5
	
	echo "Creating source cloud details"
	curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/aws-cloud-details.json" https://$(velostrata_ip)/velostrata/api/v42/cloud/details > /dev/null
	sleep 15
	
	echo "Creating cloud extensions"
	$(eval task = $(shell curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/cloud-extensions.json" https://$(velostrata_ip)/velostrata/api/v42/cloudextensions 2>/dev/null | jq -r '.value'))
	sleep 10
	echo "Checking task $(task)... this could take up to 5 mins..."

	state="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.state')" && \
	progress="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.progress')" && \
	while [ "$$state" != "Succeeded" ] ; do \
		echo "Status: \"$$state\"... \"$$progress\"%, retrying in 30 seconds..." ; \
		sleep 30 ; \
		state="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/t-2" 2>/dev/null | jq -r '.state')" ; \
		progress="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/velostrata/api/v42/tasks/$(task)" 2>/dev/null | jq -r '.progress')" ; \
	done; 
	
	rm -f ${DIR}/out/runbook.csv
	echo "Generating runbook..."
	curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST -d "@${DIR}/out/generate-runbook.json" -O -J  https://$(velostrata_ip)/auto/rest/runbooks
	echo "Updating runbook..."
	mkdir -p out
	awk -F, -v OFS=, 'NR>1{$$1="1"; $$15="n1-standard-4"; $$17="$(gcp_workload_subnet_id)"}{print}' Velostrata_Runbook.csv > ${DIR}/out/runbook.csv
	rm Velostrata_Runbook.csv
	echo "Creating wave..."
	curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: text/csv" -X PUT --upload-file ${DIR}/out/runbook.csv https://$(velostrata_ip)/auto/rest/waves/w1  > /dev/null
	echo "Validating wave..."
	curl -k -s --user apiuser:wpdemo1234 -X POST https://$(velostrata_ip)/auto/rest/waves/w1/validations  > /dev/null

	echo "DONE"	

migrate: ## Run migration job
	echo "Running cloud migration for wave w1"
	curl -k -s --user apiuser:wpdemo1234 -H "Content-Type: application/json" -X POST https://$(velostrata_ip)/auto/rest/waves/w1?type=RunInCloud  > /dev/null

	echo "\nThe migration could take up to 15 mins.... cheking status:"
	sleep 30
	state="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/auto/rest/waves/w1" 2>/dev/null | jq -r '.lastJob.status')" && \
	while [ "$$state" == "Running" ] ; do \
		echo "Status: \"$$state\"..., retrying in 30 seconds..." ; \
		sleep 30; \
		state="$$(curl -k -s --user apiuser:wpdemo1234 "https://$(velostrata_ip)/auto/rest/waves/w1" 2>/dev/null | jq -r '.lastJob.status')" && \
	done;

update_instance_group: ## Update instance group for the load balancer
	$(call dockerRun, bash -c "export GCP_PROJECT=$(strip $(GCP_PROJECT)) \
		&& export GCP_ZONE=$(strip $(gcp_region))-a \
		&& envsubst<templates/update_instance_group.sh.tpl>out/update_instance_group.sh")
	chmod 777 ${DIR}/out/update_instance_group.sh	
	$(call dockerRun, out/update_instance_group.sh)	

clean: ## Destroy velostrata instances
	$(call dockerRun, bash -c "export GCP_PROJECT=$(strip $(GCP_PROJECT)) \
		&& export GCP_ZONE=$(strip $(gcp_region))-a \
		&& envsubst<templates/delete_velostrata.sh.tpl>out/delete_velostrata.sh")
	chmod 777 ${DIR}/out/delete_velostrata.sh	
	$(call dockerRun, out/delete_velostrata.sh)

exec: ## Execs into the builder container
	$(call dockerRun, bash)

define dockerRun
	mkdir -p $(OUT_DIR)
	docker run -it \
				-e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			    -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			    -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			    -v ${GCLOUD_KEYFILE_JSON}:/root/.gcp/terraform_sa.json \
			    -v $(shell pwd):/project \
			    demo-tools:latest $(1)
endef