variable "region" { type = string default = "us-east-1" }
variable "cluster_name" { type = string default = "micro-eks" }
variable "ecr_repos" { type = list(string) default = ["users","orders"] }
