resource "aws_s3_bucket" "example" {
  bucket = "mybucket123"
  acl    = "public-read"

  versioning {
    enabled = true
  }
}
