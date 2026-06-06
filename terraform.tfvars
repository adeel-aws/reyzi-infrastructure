aws_region   = "us-east-1"
project_name = "reyzi"
environment  = "dev"

####  State S3

state_bucket_name = "state-bucket-2k26"

#### DynamoDB Table

table_name     = "reyzi-state-locking"
billing_mode   = "PAY_PER_REQUEST"
hash_key       = "LockID"
attribute_name = "LockID"
attribute_type = "S"

#### FRONTEND S3

frontend_bucket_name      = "frontend-bucket-2k26"
enable_static_website     = false
enable_versioning         = true
enable_lifecycle_rule     = true
lifecycle_expiration_days = 60
lifecycle_transition_days = 30
lifecycle_storage_class   = "STANDARD_IA"
enable_logging            = false
aliases                   = ["www.adeeltech.bar"]

###    ACM    ###

domain_name               = "adeeltech.bar"
auto_validate_via_route53 = false
subject_alternative_names = ["www.adeeltech.bar"]


#### VPC ####
vpc_name        = "my-vpc"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
azs             = ["us-east-1a", "us-east-1b"]

enable_nat_gateway = true
create_eip         = true

create_app_sg = true
create_elb_sg = true
create_db_sg  = false

#### ELB SG RULES (ONLY PUBLIC ENTRY POINT)
elb_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

####    ECR     ####

repository_name = "backend"
scan_on_push    = true

####  Secrets  ####

secrets_name = "mongo-uri"
# mongo_uri is passed via environment variable TF_VAR_mongo_uri
# mongo_uri    = 

####   ECS   ####

enable_alb = true
# enable_https    = true
enable_logs = true
enable_exec = true

deployment_min_healthy    = 50
deployment_max_percent    = 200
enable_blue_green         = false
log_retention_days        = 7
health_check_grace_period = 120

assign_public_ip = false
FRONTEND_URL     = "https://www.adeeltech.bar,https://adeeltech.bar,https://dqvimiox59exy.cloudfront.net"
jwt_secret = "**********"