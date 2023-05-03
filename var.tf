variable   "bucket_name"     {
 type = string
}
variable "destination_bucket_name" {
 type = string
}

variable "origin_region"{
type = string
}

variable  "replica_region"{         
type = string
}

variable "versioning"{
 type = string
 #default = "Enabled"
}
