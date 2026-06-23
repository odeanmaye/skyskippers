# S3 and CloudFront Permissions

This Terraform config fixes the common `AccessDenied` case where CloudFront is pointed at a private S3 bucket but the bucket policy does not allow that CloudFront distribution to read objects.

It assumes:

- S3 bucket already exists: `skyskippers`
- CloudFront distribution already exists: `E1VF9CL2NFX8KT`
- CloudFront uses S3's REST origin with Origin Access Control, not the S3 static website endpoint

Run:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

If you use a named AWS profile:

```bash
terraform plan -var='aws_profile=your-profile'
terraform apply -var='aws_profile=your-profile'
```

After applying, deploy the site from the repo root:

```bash
npm run deploy
```

If CloudFront still returns `AccessDenied`, check the distribution origin. It should use the S3 REST endpoint, such as:

```text
skyskippers.s3.us-east-1.amazonaws.com
```

It should not use the S3 website endpoint, such as:

```text
skyskippers.s3-website-us-east-1.amazonaws.com
```

If the distribution is still using legacy Origin Access Identity instead of Origin Access Control, this policy will not be enough; the distribution should be migrated to OAC or the bucket policy must use the OAI principal.
