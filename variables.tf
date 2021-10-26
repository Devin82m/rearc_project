### Variables file for rearc-deploy.tf if you want to change things up. 
### Devin St. Clair 2021-10-25

variable "region_name" {
    type        = "string"
    description = "AWS Region"
}
variable "tag_name" {
    type        = "string"
    description = "Simple tag to identify all resources related to the project"
}
