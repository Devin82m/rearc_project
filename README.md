# Devin's Quest

## Summary
![image](https://user-images.githubusercontent.com/3453106/138580640-b72e7739-97b4-40d8-9766-49b8fad3171e.png)

This project is a skills assessment for Rearc. The project was a blast to work on, it helped work the cobwebs out. I always love seeing my automation go out and do all the things in a few seconds or minutes when doing it manually would have take much longer. I had some issues with Docker, specifically remembering to rebuil the image after changing the Dockerfile. I also has several issues with Terraform, trying to figure out the ALB, TG and ACM module requirements which are not documented very well. But I just handled each issue as it came, fix the first issue in the list, the running 'terrform plan' again to see what's left. Once that was completed there were some more issues that Terraform Plan did not find related to having multiple subnets for the ALB (I forgot to translated what I do that during the manual configuration to my automation). I want to thank Rearc for deisgning this run project!

*** Disclaimer: Run this at your own risk. I am not responsible for any costs or damage it may incur. ***

## Prerequisites

- Git 'https://git-scm.com/'
- AWS-CLI (configured with key/secret that has access to all VPC/Subnet/IG, EC2, SG, ALB, and ACM) 'https://aws.amazon.com/cli/'
- Terraform 'https://www.terraform.io/downloads.html'

## Instructions

1. Cone the Git repo 'git clone https://github.com/Devin82m/rearc_project.git'
2. Navigate to the repo 'cd /rearc_project'
3. Install all Terraform modules 'terraform init'
4. Check for Terraform script errors 'terraform plan'
5. If all checks out with plan then procede with deploying 'terraform apply'
6. After the script has run at the bottom you will see a URL for the ALB. Just add https:// on the front and navigate to it in your browser of choice

### NOTE: It make take several minutes for the ALB and Target Group to move into a Healthy state and allow traffic
