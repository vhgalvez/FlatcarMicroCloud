#!/bin/bash

# Define the directory containing your Terraform configuration files
TERRAFORM_DIR="/home/victory/infra_code/cluster_openshift_kvm-libvirt_terraform/mv_01-Ignition_kvm_cluster_libvirt_terraform_flatcar_container_linux"

# List of files to be concatenated and displayed
FILES=("main.tf" "variables.tf" "terraform.tfvars" "README.md")

# Loop through each file and display its contents
for file in "${FILES[@]}"; do
    echo "============================================================"
    echo "Contents of $file:"
    echo "============================================================"
    cat "$TERRAFORM_DIR/$file"
    echo ""  # Adds an empty line for better readability between files
done

# Listing all virtual machines
echo "Listing all virtual machines:"
sudo virsh list --all

# Display the current working directory
echo "Current working directory:"
pwd

# Additional file displays and system checks
echo "Displaying additional Terraform files and checking system directories:"
cat "$TERRAFORM_DIR/variables.tf"
cat "$TERRAFORM_DIR/terraform.tfvars"
cat "$TERRAFORM_DIR/main.tf"
tree -h "$TERRAFORM_DIR"
sudo ls -l /home/victory/infra_code/kvm_cluster_terraform/configs

# Display the current working directory again for clarity
echo "Revisiting the current working directory:"
pwd

# List all virtual machines again to show any changes or current state
echo "Listing all virtual machines after operations:"
sudo virsh list --all
