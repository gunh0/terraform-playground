# Variables
ENV ?= dev
WORKSPACE = t-security-demo-$(ENV)

# Terraform commands with automatic workspace handling
.PHONY: init plan apply destroy clean fmt validate lint show output get-svc

# Initialize terraform and select workspace
init:
	@echo "Initializing Terraform..."
	terraform init
	terraform workspace select $(WORKSPACE) 2>/dev/null || terraform workspace new $(WORKSPACE)

# Format check and validation
fmt:
	@echo "Checking Terraform format..."
	terraform fmt -check -recursive

validate: init
	@echo "Validating Terraform configuration..."
	terraform validate

# Linting (requires tflint to be installed)
lint:
	@echo "Linting Terraform files..."
	tflint --recursive

# Plan with output stored in a file
plan: init validate
	@echo "Planning Terraform changes for $(WORKSPACE)..."
	terraform plan -out=tfplan

# Apply the plan
apply: plan
	@echo "Applying Terraform changes for $(WORKSPACE)..."
	terraform apply tfplan
	@rm -f tfplan

# Clean up plans and local state
clean:
	@echo "Cleaning up..."
	rm -f tfplan
	rm -rf .terraform/

# Show current state
show:
	@echo "Showing current state..."
	terraform show

# Display specific outputs
output:
	@echo "Displaying outputs..."
	terraform output

# Get nginx service status
get-svc:
	@echo "Getting nginx service status..."
	kubectl get svc nginx

# Destroy all resources
destroy: init
	@echo "WARNING: This will destroy all resources in $(WORKSPACE)"
	@echo "Are you sure? [y/N]"
	@read -r resp; if [ "$$resp" = "y" ]; then \
		terraform destroy; \
	else \
		echo "Destroy cancelled"; \
	fi

# Full deployment pipeline
deploy: fmt validate lint plan apply get-svc

# Help target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform and select workspace"
	@echo "  fmt       - Check Terraform formatting"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  lint      - Lint Terraform files"
	@echo "  plan      - Create and show deployment plan"
	@echo "  apply     - Apply the deployment plan"
	@echo "  clean     - Clean up local Terraform files"
	@echo "  show      - Show current state"
	@echo "  output    - Show Terraform outputs"
	@echo "  get-svc   - Get nginx service status"
	@echo "  destroy   - Destroy all resources (with confirmation)"
	@echo "  deploy    - Run full deployment pipeline"
	@echo ""
	@echo "Usage:"
	@echo "  make [target] ENV=[dev|staging|prod]"
	@echo "  Default ENV=dev"