# Testimonial Grid Sections

A responsive testimonial grid section built with HTML and CSS, showcasing customer testimonials in a clean, modern layout adaptable to all device sizes.

---

## Table of Contents

- [Overview](#overview)  
- [DevOps Infrastructure and Pipeline](#devops-infrastructure-and-pipeline)  
- [Features](#features)  
- [Getting Started](#getting-started)  
- [Usage](#usage)  
- [Project Structure](#project-structure)  
- [Technologies Used](#technologies-used)  
- [Contributing](#contributing)  
- [License](#license)  

---

## Overview

This repository contains the source code for a testimonial grid section built with semantic HTML and CSS. It emphasizes responsiveness, accessibility, and clean design.

---

## DevOps Infrastructure and Pipeline

This project also demonstrates a fully automated AWS infrastructure and CI/CD pipeline managed via Terraform, which provisions and orchestrates:

- **Virtual Private Cloud (VPC)** with public and private subnets, route tables, and internet gateways, ensuring secure and scalable networking.
- **Amazon EC2 Instances** enhanced with the **AWS CodeDeploy agent** for zero-downtime, automated application deployments.
- **AWS CodeDeploy** to coordinate deployments of application updates to EC2 instances reliably.
- **AWS CodeBuild** to build, test, and package the application artifacts on each code change.
- **AWS CodePipeline** to automate the flow from source code repository through build and deployment stages.
- **Amazon S3** as secure artifact storage for build outputs, not hosting the static website directly.

The entire infrastructure is declared as code using Terraform configurations located in the `Terraform/` directory, enabling repeatable, version-controlled, and scalable deployments.

---

## Features

- Responsive, accessible testimonial grid design  
- Terraform-managed AWS infrastructure for networking, compute, and deployment  
- Automated continuous integration and delivery pipeline  
- EC2 instances managed and updated via CodeDeploy  
- Secure artifact storage with Amazon S3  

---

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/HasanAbdirahman/Testimonial-grid-sections.git

2. Navigate into the project directory:
     ```bash
     cd Testimonial-grid-sections

3. Preview the testimonial grid locally by opening:
    ```bash
    index.html

4. Deploy or update AWS infrastructure and pipeline using Terraform (inside the Terraform/ directory):
    Configure AWS credentials and variables
    Initialize Terraform:
    ```bash
    terraform init

5. Review the deployment plan:
    ```bash
    terraform plan

6. Apply the configuration:
   ```bash
   terraform apply


## Usage
Edit index.html to add or update testimonials.
Customize styling by modifying style.css.
Manage or extend infrastructure and pipeline with Terraform scripts in the Terraform/ folder.


## Project Structure

Testimonial-grid-sections/
├── images/                          # Image assets used in the project
├── Terraform/                      # Terraform infrastructure and pipeline configs
│   ├── .terraform/                 # Terraform internal directory (auto-generated)
│   ├── awscliv2.zip               # AWS CLI installation archive
│   ├── cloudwatch.tf              # CloudWatch alarms and monitoring
│   ├── codeBuild.tf               # AWS CodeBuild project configuration
│   ├── codeDeploy.tf              # AWS CodeDeploy application and deployment groups
│   ├── codepipeline.tf            # AWS CodePipeline orchestration config
│   ├── compute.tf                 # EC2 instance provisioning and configuration
│   ├── locals.tf                  # Local variables for Terraform
│   ├── network.tf                 # VPC, subnets, route tables, and networking
│   ├── provider.tf                # AWS provider configuration
│   ├── terraform_1.5.7_linux_amd64.zip # Terraform binary archive
│   ├── terraform.tfstate          # Terraform state file (auto-generated)
│   ├── terraform.tfstate.backup   # Terraform backup state file
│   ├── variables.tf               # Input variables for Terraform
│   ├── .gitignore                 # Git ignore for Terraform folder
│   └── my-buildspec.yml           # Build specification for CodeBuild
├── appspec.yml                    # AWS CodeDeploy deployment specification
├── index.html                    # Main testimonial grid HTML page
├── style.css                     # CSS styling for the grid layout and design
├── README.md                     # This README file
├── terraform.tfstate             # Terraform state file (root)


### Technologies Used

HTML5
CSS3 (Grid Layout and Flexbox)
SVG (Vector background patterns)
Terraform (Infrastructure as Code)
AWS (Amazon Web Service)


### Contributing
Contributions are welcome! Please fork the repository, create a feature branch, commit your changes, and submit a pull request.

### License
This project is licensed under the MIT License.