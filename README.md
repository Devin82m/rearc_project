# Devin's Quest

## Summary
![image](https://user-images.githubusercontent.com/3453106/138580640-b72e7739-97b4-40d8-9766-49b8fad3171e.png)

This project is a skills assessment I was challanged with by the people at Rearc. The project was a blast to work on, it helped work the cobwebs out of me. I haven't touches AWS in nearly 3 years and Terraform in nearly 4. I always love seeing my automation go out and do all the things in a few seconds or minutes, when doing it manually would have take much longer. I had some issues with Docker, specifically remembering to rebuild the image after changing the Dockerfile. I also had several issues with Terraform, trying to figure out the ALB, TG and ACM module requirements, which are not documented very well. But I just handled each issue as it came, fixed the first issue in the list, then running `terrform plan` again to see what's left. Once that was completed there were some more issues that Terraform Plan did not find related to having multiple subnets for the ALB. I spent about a total of 10 hours on this, but I think I could do it in under 2 hours now that I remember how to do a few things. I want to thank Rearc for deisgning this fun project!

*** Disclaimer: Run this at your own risk. I am not responsible for any costs or damage it may incur. ***


## Prerequisites

- Git https://git-scm.com/
- AWS-CLI (configured with a key/secret that has permissions to all VPC/Subnet/IG, EC2, SG, ALB, and ACM resources) https://aws.amazon.com/cli/
- Terraform https://www.terraform.io/downloads.html


## Instructions

1. Cone the Git repo `git clone https://github.com/Devin82m/rearc_project.git`
2. Navigate to the repo `cd /rearc_project`
3. Install all Terraform modules `terraform init`
4. Check for Terraform script errors `terraform plan`
5. If all checks out with plan then procede with deploying `terraform apply`
6. After the script has run, at the bottom of your CLI you will see a URL for the ALB. Just add **https://** on the front and navigate to it in your browser of choice

### NOTE: It make take several minutes for the ALB and Target Group to move into a Healthy state and allow traffic.
