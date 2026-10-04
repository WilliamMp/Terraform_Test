# Secure three-tier AWS infrastructure

Terraform implementation of the infrastructure-only DevOps technical test. It separates internet-facing access, processing with internet egress, and isolated sensitive-data processing.

## Scope and validation

The infrastructure defines the required services and permissions. Application logic and a deployment pipeline are outside the test scope.

Both Lambdas currently use a placeholder Python handler that returns HTTP 501. It does not call the private API, write to S3, or sanitize business data. The application flow below is the intended flow supported by the infrastructure, not a completed end-to-end application.

Local checks reported by the author:
- `terraform init -backend=false`: succeeded.
- `terraform fmt -recursive`: no changes.
- `terraform validate`: 0 errors and 0 warnings.

No AWS account was available. Remote backend initialization, an AWS-backed plan, deployment, connectivity, and runtime authorization have not been tested. Static validation is not evidence of a successful deployment.

## Architecture

One VPC (`10.0.0.0/16`) contains two subnets per tier across `us-east-1a` and `us-east-1b`.

| Tier | Resources and connectivity |
| --- | --- |
| Public | NAT gateway in public_a; default route to the internet gateway. No application compute. |
| Private | First Lambda uses private subnets; default route through NAT and outbound HTTPS permitted. |
| Isolated | Sensitive-processing Lambda and execute-api interface endpoint ENIs; no internet default route. Lambda outbound HTTPS is limited to the S3 prefix list. |

API Gateway is an AWS-managed service, not a server placed in a subnet. The private API is reached through interface endpoint ENIs in the isolated subnets. S3 is accessed through a gateway endpoint associated with the isolated route table.

### Intended request flow

1. An authorized client sends a signed POST request to the regional public API at `/dev/process`.
2. WAF inspects the request; API Gateway invokes the private-tier Lambda.
3. Application code in that Lambda would sign a POST request to the private API using its execution-role credentials.
4. The request travels through the execute-api interface endpoint; the private API invokes the isolated Lambda.
5. The isolated Lambda would store processed data under `processed/` in S3 through the gateway endpoint.
6. Results return synchronously through the APIs. Application code must ensure only non-sensitive results reach the client.

Lambda invocation uses API Gateway's Lambda integration and function resource permissions; it does not require inbound application ports on the Lambda security groups.

## Repository structure

The Terraform root is `module/`. Run Terraform commands there.

| Path | Responsibility |
| --- | --- |
| `module/main.tf` | AWS provider, backend declaration, module wiring, cross-module permissions |
| `module/variables.tf` | Root inputs, defaults, and project/network locals |
| `module/version.tf` | Terraform and AWS provider requirements |
| `module/network/` | VPC, six subnets, routes, NAT, security groups, endpoints |
| `module/iam/` | Separate Lambda execution roles and permissions |
| `module/storage/` | Application bucket, encryption, ownership, access policy |
| `module/lambda/` | Functions, automatic ZIP packaging, log groups |
| `module/api/` | Public/private REST APIs, integrations, stages, permissions, logs |
| `module/waf/` | Regional web ACL associated with the public API stage |
| `module/backend.hcl.example` | Remote-state configuration template |

Provider selections and checksums are committed in `module/.terraform.lock.hcl`. The current lock selects AWS 6.67.0 and archive 2.8.1. The declared Terraform requirement is >= 1.16.

## Local validation without AWS access

Install Terraform satisfying `module/version.tf`, then:

```bash
git clone --branch dev https://github.com/WilliamMp/Terraform_Test.git
cd Terraform_Test/module
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

Provider installation needs internet access, but these checks do not require an AWS deployment. Disabling backend initialization does not make an AWS plan or apply account-free.

The archive data source packages `lambda/src/handler.py` into `lambda/function.zip`; both functions reference its path and hash. No manual ZIP command is needed. Depending on Terraform dependencies, archive evaluation occurs during planning or is deferred to apply. Preserve generated artifacts between a saved plan and its application. The committed RAR is an unused legacy file.

## Remote state and deployment prerequisites

The root declares an S3 backend. Before initializing it, provide a separate existing state bucket with versioning, encryption, public access blocked, and restricted access. This project does not create that prerequisite bucket.

Copy `backend.hcl.example` to `backend.hcl` and replace its bucket and region values. The state key separates this project/environment. Native S3 locking is enabled with `use_lockfile = true`.

The Terraform identity needs bucket listing, state-object read/write, and lock-object read/write/delete permissions. Additional KMS permissions are needed if the state bucket uses a customer-managed key. Use an AWS profile or temporary credentials; do not put credentials in backend files.

When AWS access is available, from `module/`:

```bash
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

Review the plan before approving apply. These commands are documented for future use and have not been executed against AWS. If migrating existing state, use the appropriate state migration workflow rather than blindly reconfiguring.

Local backend settings, state files, variable-value files, and generated ZIPs are ignored. Keep state, credentials, and saved plans out of Git. The example and provider lock file should remain committed.

## Security decisions

- **Separate identities:** each Lambda has its own execution role, with trust limited to the Lambda service.
- **Private API:** AWS_IAM authorization plus explicit resource-policy denials restrict calls to the expected VPC endpoint and private Lambda role. The caller role has permission only for the private stage's POST /process route.
- **Endpoint security group:** accepts HTTPS from the private Lambda security group. The API endpoint currently uses its default endpoint policy; the API resource policy supplies the identity and endpoint restrictions.
- **Public API:** regional and internet-reachable, but uses AWS_IAM authentication. Clients need execute-api permission and SigV4-signed requests. Client identity provisioning is not included.
- **Function invocation:** API Gateway permissions restrict invocation to the corresponding API's POST /process route.
- **S3:** SSE-S3 AES256 encryption, all public-access blocks enabled, ACLs disabled through BucketOwnerEnforced, and insecure transport denied.
- **Sensitive-data writes:** the isolated role and S3 endpoint policy allow PutObject only under processed/*. Bucket policy denies object access by other identities and denies GetObject/PutObject outside the expected endpoint. No application GetObject, ListBucket, or DeleteObject permission is granted.
- **WAF:** AWSManagedRulesCommonRuleSet protects the public stage. Metrics are enabled; request sampling is disabled.
- **Logging:** API access logs contain request metadata without bodies or authorization headers. Lambda and API log groups default to 14-day retention. Application code must also avoid logging sensitive payloads.

## Trade-offs and operational limitations

- One NAT gateway reduces test cost and complexity but is an availability dependency for both private subnets and can cause cross-AZ traffic.
- Private-tier HTTPS egress permits any destination. NAT supplies connectivity; it does not filter destinations.
- AWSLambdaVPCAccessExecutionRole provides practical networking/logging permissions but includes Resource = "*".
- The S3 object restriction also denies administrator object operations unless the policy is deliberately adjusted. A populated bucket needs an authorized cleanup procedure before deletion.
- API Gateway's CloudWatch role setting is account/region-wide. Coordinate or import existing configuration in a shared account.
- Two-AZ subnet placement supports expansion, but concurrency limits, API throttles, load testing, and availability behavior remain untested.
- Application code must implement signed private-API calls, error handling, S3 uploads, and response sanitization. The caller's private API URL will need to be supplied when that code is implemented.
- No custom alarms, dashboards, WAF log delivery, deployment pipeline, or application implementation is included.

## AI assistance

I used AI to help draft Terraform configuration, troubleshoot validation errors, review subnet segmentation and API Gateway access controls, and explore AWS WAF configuration. Local Terraform validation completed with no errors or warnings. The infrastructure has not been deployed or tested in AWS.

## Improvements with more time

- Allow discovery of an existing VPC and subnets through data sources.
- Add stricter destination filtering for private-tier egress.
- Narrow operational IAM permissions where supported.
- Add a restricted execute-api endpoint policy as another access-control layer.
- Use one NAT gateway and private route table per AZ where availability justifies the cost.
- Consider customer-managed KMS keys and data lifecycle/versioning requirements.
- Add alarms, dashboards, throttling, and WAF rate controls based on operational needs.
- Implement and test the application flow, negative authorization cases, failure handling, and sensitive-data redaction.
- GitHub Actions: Define environment-specific defaults to reduce manual input and keep deployments consistent.
- Product flexibility: Make selected resources optional through Terraform variables and conditional creation, based on user     requirements.
- Resource review: Evaluate whether each resource is necessary for the intended use case, considering cost, security, and operational complexity.
- Production IP capacity: Assess available subnet IP addresses and expected growth before deployment to avoid IP exhaustion and disruption to existing workloads.

## References

- [Terraform S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Terraform archive data source](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)

