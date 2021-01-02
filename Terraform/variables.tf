variable "project_name" {
  type = string
  description = "The project name, which will be used to construct various resource names."
  default = "covid-19-puerto-rico"
}

variable "main_bucket_name" {
  type = string
  description = "The name of the base S3 bucket to create/use."
  default = "covid-19-puerto-rico"
}

variable "datalake_bucket_name" {
  type = string
  description = "The name of the datalake bucket to create/use. This is where downloads will be stored."
  default = "covid-19-puerto-rico-data"
}

variable "athena_bucket_name" {
  type = string
  description = "The name of the bucket to create/use for Athena query results and tables."
  default = "covid-19-puerto-rico-athena"
}
