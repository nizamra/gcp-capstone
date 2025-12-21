# gcp-capstone/Makefile

# --- Colors ---
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RED    := $(shell tput -Txterm setaf 1)
RESET  := $(shell tput -Txterm sgr0)

# --- Configuration ---
GCP_PROJECT_ID ?= gcp-capstone-481414
GCP_REGION     ?= us-central1
GCP_ZONE       ?= us-central1-a
# TERRAFORM_DIRS := networking security registry gke observability
TERRAFORM_DIRS := networking

# --- Terraform Backend ---
TF_STATE_BUCKET ?= $(ENV)-gcp-capstone-tf-state-$(GCP_PROJECT_ID)
TF_BACKEND_CONF := -backend-config="bucket=$(TF_STATE_BUCKET)" -backend-config="prefix=$(MODULE)"


# --- Phony Targets ---
.PHONY: help bootstrap init plan apply destroy validate fmt lint clean

# --- Help ---
help: ## make <target> MODULE=networking ENV=dev
	@echo ""
	@echo "$(GREEN)GCP Capstone – Terraform Control Plane$(RESET)"
	@echo ""
	@echo "Usage:"
	@echo "  make apply MODULE=networking ENV=dev"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

bootplan: ## make bootplan GCP_PROJECT_ID=gcp-capstone-481414 ENV=dev
	@echo "$(YELLOW)⚠️  Running bootstrap (one-time operation)$(RESET)"
	cd bootstrap && terraform init && terraform plan -var-file="values.$(ENV).tfvars" -var="project_id=$(GCP_PROJECT_ID)"
	@echo ""
	@echo "If the plan looks correct, run:"
	@echo "  make bootapply"

bootapply: ## make bootapply GCP_PROJECT_ID=gcp-capstone-481414 ENV=dev
	@echo "$(GREEN)=== Applying bootstrap (one-time operation) for $(ENV) ===$(RESET)"
	cd bootstrap && terraform apply -var-file="values.$(ENV).tfvars" -var="project_id=$(GCP_PROJECT_ID)" -auto-approve

bootdestroy: ## make bootdestroy GCP_PROJECT_ID=gcp-capstone-481414 ENV=dev
	@echo "$(RED)🔥 DESTROYING bootstrap (one-time operation) for $(ENV) 🔥$(RESET)"
	cd bootstrap && terraform destroy -var-file="values.$(ENV).tfvars" -var="project_id=$(GCP_PROJECT_ID)" -auto-approve

bootclean: ## make bootclean
	@echo "$(YELLOW)=== Cleaning bootstrap Terraform cache ===$(RESET)"
	@cd bootstrap && rm -rf .terraform && rm -f .terraform.lock.hcl

init: ## make init ENV=dev
	@echo "$(GREEN)=== Initializing Terraform Backend for $(ENV) ===$(RESET)"
	@if [ ! -f terraform/backend.tfvars ]; then \
		echo "bucket = \"$(GCP_PROJECT_ID)-$(ENV)-tf-state\"" > terraform/backend.tfvars; \
		echo "prefix = \"$(ENV)\"" >> terraform/backend.tfvars; \
	fi
	cd terraform && terraform init -backend-config=backend.tfvars

plan: ## make plan ENV=dev
	@echo "$(GREEN)=== Planning all modules for $(ENV) ===$(RESET)"
	@cd terraform && \
	terraform plan \
		-var-file="values.$(ENV).tfvars" \
		-var="project_id=$(GCP_PROJECT_ID)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \

apply: ## make apply ENV=dev
	@echo "$(GREEN)=== Applying all modules for $(ENV) ===$(RESET)"
	@cd terraform && \
	terraform apply \
		-var-file="values.$(ENV).tfvars" \
		-var="project_id=$(GCP_PROJECT_ID)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \
		-auto-approve

destroy: ## make destroy ENV=dev
	@echo "$(RED)🔥 DESTROYING all modules for $(ENV) 🔥$(RESET)"
	@cd terraform && \
	terraform destroy \
		-var-file="values.$(ENV).tfvars" \
		-var="project_id=$(GCP_PROJECT_ID)" \
		-var="region=$(GCP_REGION)" \
		-var="zone=$(GCP_ZONE)" \
		-auto-approve

validate: ## make validate
	@echo "$(GREEN)=== Validating Terraform modules ===$(RESET)"
	terraform -chdir=terraform fmt -recursive -check && \
	terraform -chdir=terraform validate -recursive; \

fmt: ## make fmt
	@echo "$(GREEN)=== Formatting Terraform code ===$(RESET)"
	@terraform fmt -recursive

lint: ## make lint
	@echo "$(GREEN)=== Linting Terraform ===$(RESET)"
	@for dir in $(TERRAFORM_DIRS); do \
		tflint --chdir=terraform || true; \
	done

clean: ## make clean
	@echo "$(YELLOW)=== Cleaning Terraform cache ===$(RESET)"
	@find . -type d -name ".terraform" -exec rm -rf {} +
	@find . -name ".terraform.lock.hcl" -delete
