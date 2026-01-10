project_name      = "umami"
aws_region        = "eu-north-1"

# Use your real VPC + subnets (the same ones your ALB/ECS are in)
vpc_id            = "vpc-07047b791a19633e5"
public_subnet_ids = ["subnet-0fa891062ee7b83f8","subnet-0633db66d3cc61255"]
private_subnet_ids = ["subnet-0fa891062ee7b83f8","subnet-06d7ba10b47565eea","subnet-014fcfce80df3c1bf","subnet-0633db66d3cc61255"] # put your real private subnets here

app_port          = 3000

db_name           = "umami"
db_username       = "umami"

domain_name       = "mhecsproject.com"
subdomain         = "tm"
hosted_zone_id    = "Z04887172DPZ00NG95JRN"
