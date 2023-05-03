locals {
  create_bucket = var.create_bucket 
}

resource "aws_s3_bucket" "this" {
  count = local.create_bucket ? 1 : 0

  bucket        = var.bucket

  tags                = var.tags

  
}

resource "aws_s3_bucket_versioning" "this" {
  count = local.create_bucket && length(keys(var.versioning)) > 0 ? 1 : 0

  bucket                = aws_s3_bucket.this[0].id
  
  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))

  }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = local.create_bucket && length(keys(var.replication_configuration)) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  role   = var.replication_configuration["role"]

  dynamic "rule" {
    for_each = flatten(try([var.replication_configuration["rule"]], [var.replication_configuration["rules"]], []))

    content {
      id       = try(rule.value.id, null)

      status   = try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)), "Enabled")

      dynamic "destination" {
        for_each = try(flatten([rule.value.destination]), [])

        content {
          bucket        = destination.value.bucket
          storage_class = try(destination.value.storage_class, null)
         
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_public_access_block" "block_public_source" {
 # provider      = aws.sourced
 # bucket = aws_s3_bucket.source.id
  count = local.create_bucket ? 1 : 0

  bucket        =  aws_s3_bucket.this[0].id


  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}
