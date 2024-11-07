#!/bin/bash

# Define the directory containing your Terraform configuration files
TERRAFORM_DIR="/home/victory/infra_code/cluster_openshift_kvm-libvirt_terraform/mv_02-cloud-init_cluster_kvm_rockylinux_libvirt_terraform"

# Define the config directory path
CONFIG_DIR="$TERRAFORM_DIR/config"

# Display the tree structure of the Terraform directory
echo "Displaying directory tree for Terraform configuration files:"
tree -lh "$TERRAFORM_DIR"

# Display the current working directory
echo "Current working directory:"
pwd

# List all virtual machines and their states
echo "Listing all virtual machines:"
sudo virsh list --all

# List of files to be concatenated and displayed from the main directory
FILES=("main.tf" "meta-data" "outputs.tf" "provider.tf" "README.md" "terraform.tfvars" "user-data" "vars.tf")

# Loop through each file in the main directory and display its contents
for file in "${FILES[@]}"; do
    echo "============================================================"
    echo "Contents of $file:"
    echo "============================================================"
    cat "$TERRAFORM_DIR/$file"
    echo ""  # Adds an empty line for better readability between files
done

# Additional files in the config directory
CONFIG_FILES=("bastion1-user-data.tpl" "freeipa1-user-data.tpl" "load_balancer1-user-data.tpl" "postgresql1-user-data.tpl")

# Loop through each file in the config directory and display its contents
for config_file in "${CONFIG_FILES[@]}"; do
    echo "============================================================"
    echo "Contents of $config_file:"
    echo "============================================================"
    cat "$CONFIG_DIR/$config_file"
    echo ""  # Adds an empty line for better readability between files
done
