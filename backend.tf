# Remote terraform statefile configuration to specified S3 bucket
terraform {
  backend "s3" {
    bucket       = "s3-state-bucket-dolapo-ai-screenplay-analyzer"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true #S3 native locking
  }
}