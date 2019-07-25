.SILENT: destroy init plan exec update_host apply

init: ## Inits terraform
	$(call dockerRun, terraform init)

plan: ## Creates the plan to install WordPress in Aws, set up networks in both aws and gcp
	echo "Terraform plan"
	$(call dockerRun, terraform plan $(VAR_FILE) $(PLAN_OUT) $(STATE))

apply: ## Executes the terraform plan
	$(call dockerRun, terraform apply $(STATE_OUT) $(PLAN))
	echo "Apply finished successfuly!"
	echo "Please run update_host target with sudo privileges as indicated in the terraform output..."

destroy: ## Cleans up the created resources in aws and gcp
	echo "Terraform destroy"
	$(call dockerRun, terraform destroy $(VAR_FILE) $(STATE) -auto-approve)

exec: ## Execs into the builder container
	$(call dockerRun, bash)

update_host: WP_IP := $(strip $(shell dig +short $(wp_dns)))
update_host:  ## Updates local etc/hosts with WP ip. Requires wpip env variable to be set.
	sudo bash -c "grep -q 'wp-demo' /etc/hosts && sed -i '' 's/.* wp-demo/$(WP_IP)    wp-demo/g' /etc/hosts || echo '$(wpip)    wp-demo' >> /etc/hosts"

open_demo:
	open http://wp-demo


define dockerRun
	mkdir -p $(OUT_DIR)
	docker run -it -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
			   -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
			   -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
			   -v ${GCLOUD_KEYFILE_JSON}:/root/.gcp/terraform_sa.json \
			   -v $(shell pwd):/project \
			   demo-tools:latest $(1)
endef

OUT_DIR=./out
VAR_FILE=-var-file=variables.tfvars
STATE_FILE=$(OUT_DIR)/terraform.tfstate
STATE_OUT=-state-out=$(STATE_FILE)
STATE=-state=$(STATE_FILE)
PLAN=$(OUT_DIR)/terraform.plan
PLAN_OUT=-out=$(PLAN)
