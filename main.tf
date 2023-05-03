provider "aws" {

 region  = "us-east-2"
}

provider "aws" {
   alias = "source"
   region = local.origin_region
}

provider "aws" {
  region = local.replica_region

  alias = "replica"
}

locals {
  bucket_name             = var.bucket_name
  destination_bucket_name = var.destination_bucket_name
  origin_region           = var.origin_region
  replica_region          = var.replica_region
}





module "replica_bucket" {
  source = "./module/s3"

  providers = {
    aws = aws.replica
  }

  bucket = local.destination_bucket_name
  acl    = "private"

  versioning = {
  #  enabled = true
  #  status = "true"
     status = var.versioning
  }

  
}

module "s3_bucket" {
  source = "./module/s3"
   providers = {
    aws = aws.source
  }
  bucket = local.bucket_name
  acl    = "private"

  versioning = {
 #   enabled = true
     status = var.versioning
 }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "replication rule"
        #status   = "Enabled"
         status = var.versioning     
    

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"
        }
      },
      
    ]
  }

}
