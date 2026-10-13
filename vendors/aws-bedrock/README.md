# Amazon Bedrock vendor pack

**Verified as of 2026-10-13** against AWS documentation, the `hashicorp/aws` provider schema (v6.68.0, from `terraform providers schema -json`) and the CloudFormation resource schemas bundled with cfn-lint 1.57.2. Sources are listed in `mapping.yaml` and docs/SOURCES.md.

## Purpose

This pack sets a secure-by-default governance baseline for generative AI on Amazon Bedrock:

- A baseline **guardrail**, enforced across the organization and the account.
- A **model allow-list** and a **Region restriction**, both through service control policies (SCPs).
- **Model invocation logging**. AWS leaves it off by default.
- Optional **PrivateLink** endpoints and **customer managed KMS keys**.

Every resource carries its control IDs (`# AIG-xx`) in a comment. The same IDs appear in [`mapping.yaml`](mapping.yaml).

## What is enforced

| Control | Mechanism | Terraform | Native |
|---|---|---|---|
| AIG-05 Personal data | Guardrail sensitive-information filters. EMAIL, PHONE, NAME and ADDRESS are anonymised. Card number, CVV, password and AWS access and secret keys are blocked. Extra PII types and regexes come from variables. | `terraform/main.tf` `aws_bedrock_guardrail.baseline` | `native/cloudformation/guardrail.yaml` `Guardrail` |
| AIG-06 Approved models | SCP `AIG06DenyUnapprovedBedrockModels`. It denies `InvokeModel` and `InvokeModelWithResponseStream` with `NotResource` set to the approved foundation-model and inference-profile ARNs. Denying `InvokeModel` also blocks Converse and StartAsyncInvoke. | `terraform/organizations.tf` `aws_organizations_policy.bedrock_scp` | `native/scp/deny-unapproved-models.json` |
| AIG-10 Runtime guardrails (enforced via IAM) | SCP `AIG07AIG10DenyInvokeWithoutApprovedGuardrail` uses `StringNotEquals` on `bedrock:GuardrailIdentifier`, matched against the guardrail's ARN:version. The log-delivery role trusts only `bedrock.amazonaws.com`, scoped by `aws:SourceAccount` and `aws:SourceArn`, and can write only to the invocation log stream. The optional SCP `AIG07AIG13ProtectBedrockInvocationLogging` restricts who can change logging. | `organizations.tf`, `logging.tf` `aws_iam_role.bedrock_logging` | `native/scp/require-guardrail.json`, `native/scp/protect-invocation-logging.json` |
| AIG-08 Network and residency | Interface endpoints for `bedrock`, `bedrock-runtime` and `bedrock-agent-runtime`, with private DNS. SCP `AIG08DenyBedrockOutsideApprovedRegions` uses `aws:RequestedRegion`. Global cross-Region inference stays blocked unless you allow it. | `terraform/network.tf`, `organizations.tf` | `native/scp/restrict-regions.json` |
| AIG-09 Encryption | Optional CMKs: `kms_key_arn` on the guardrail, SSE-KMS on the log bucket, and `kms_key_id` on the log group. Without a CMK the bucket uses SSE-S3. The bucket policy is TLS-only. | `main.tf`, `logging.tf` | `guardrail.yaml` (`KmsKeyArn`), `enable-invocation-logging.sh` (`KMS_KEY_ARN`) |
| AIG-10 Runtime guardrails | Guardrail settings:<br>• HATE, INSULTS, SEXUAL, VIOLENCE and MISCONDUCT at HIGH on input and output.<br>• PROMPT_ATTACK at HIGH on input and NONE on output.<br>• Denied topic "Legal advice", configurable.<br>• Managed PROFANITY list.<br>• GROUNDING and RELEVANCE at 0.75.<br>Every change produces a numbered version. Enforcement runs at organization level (`BEDROCK_POLICY`) and at account level (`AWS::Bedrock::EnforcedGuardrailConfiguration`). | `main.tf`, `organizations.tf` `aws_organizations_policy.bedrock_guardrail_enforcement` | `guardrail.yaml`, `native/bedrock-policy.json` |
| AIG-13 Logging | | `terraform/logging.tf` | `native/enable-invocation-logging.sh` |
| AIG-15 Change management | Guardrail versions are immutable and retained (`skip_destroy`, `DeletionPolicy: Retain`). | `main.tf` `aws_bedrock_guardrail_version.baseline` | `guardrail.yaml` `GuardrailVersion` |

### CloudTrail note (AIG-13)

`InvokeModel`, `InvokeModelWithResponseStream`, `Converse` and `ConverseStream` are CloudTrail **management events**, so CloudTrail logs them by default.

The following are **data events**, which you must opt into on your organization trail:

| Operation | Resource type |
|---|---|
| `ApplyGuardrail` | `AWS::Bedrock::Guardrail` |
| `InvokeAgent` | `AWS::Bedrock::AgentAlias` |
| `InvokeInlineAgent` | `AWS::Bedrock::InlineAgent` |
| `Retrieve`, `RetrieveAndGenerate` | `AWS::Bedrock::KnowledgeBase` |
| `InvokeFlow` | `AWS::Bedrock::FlowAlias` |
| `RenderPrompt` | `AWS::Bedrock::Prompt` |
| Async and bidirectional invocations | `AWS::Bedrock::Model`, `AWS::Bedrock::AsyncInvoke` |

This pack does not manage the trail.

## How to apply

### Prerequisites and permissions

- **Terraform** >= 1.6 and `hashicorp/aws` `~> 6.68`.
- **Guardrail and logging.** Run in each workload account and **in each Region** you use, because invocation logging and account-level enforcement are set per Region. You need:
  - `bedrock:CreateGuardrail`, `bedrock:CreateGuardrailVersion` and `bedrock:PutModelInvocationLoggingConfiguration`
  - `s3:*` bucket configuration
  - `logs:CreateLogGroup` and `logs:PutRetentionPolicy`
  - `iam:CreateRole`, `iam:PutRolePolicy` and `iam:PassRole`
  - `kms:DescribeKey`, `kms:CreateGrant`, `kms:GenerateDataKey` and `kms:Decrypt`, if you use a CMK
- **Organization policies** (`manage_organization_policies = true`):
  - Run from the **AWS Organizations management account**, or from a delegated policy administrator.
  - The `SERVICE_CONTROL_POLICY` and `BEDROCK_POLICY` policy types must be enabled on the root. Use `aws organizations enable-policy-type`.
  - For `BEDROCK_POLICY`, the guardrail must be **owned by the management account**, created in the Region named in the policy, referenced as `ARN:version` (never `DRAFT`), and shared with the organization through a resource-based policy that allows `bedrock:ApplyGuardrail`. The resource-based policy is the `GuardrailOrganizationPolicy` resource in `guardrail.yaml`; set the `OrganizationId` parameter to create it.
  - Member-account roles need `bedrock:ApplyGuardrail` on that guardrail.
  - SCPs do not apply to the management account.
- **CMK key policies.**
  - The guardrail key must grant creators `kms:Decrypt`, `GenerateDataKey`, `DescribeKey` and `CreateGrant`, and grant callers `kms:Decrypt`.
  - The logging key must grant `bedrock.amazonaws.com` `kms:GenerateDataKey`, with `aws:SourceAccount` and `aws:SourceArn` conditions. It must also let `logs.<region>.amazonaws.com` use the key, with a `kms:EncryptionContext:aws:logs:arn` condition.

### Terraform

```bash
cd vendors/aws-bedrock/terraform
cp terraform.tfvars.example terraform.tfvars   # replace placeholders
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Notes:

- Review the rendered `scp_content` and `bedrock_policy_content` outputs before you attach them. Attach them first to a test OU.
- The SCP precondition refuses to create an empty allow-list, because an empty list would deny every model. A second precondition enforces the 10,240-character SCP size limit.
- Rolling out a guardrail update:
  1. Changing the guardrail replaces `aws_bedrock_guardrail_version` (`replace_triggered_by`), which creates a new numbered version.
  2. The SCP and `BEDROCK_POLICY` follow the new version.
  3. Old versions are retained.
  4. The SCP briefly rejects callers until they switch to the new version. To overlap versions, list both in `required_guardrail_identifiers`.

### Native (CloudFormation, AWS CLI, Organizations)

```bash
# 1. Guardrail, version, account-level enforcement (+ org sharing in the management account)
aws cloudformation deploy --region ap-southeast-2 \
  --stack-name aigov-bedrock-guardrail \
  --template-file native/cloudformation/guardrail.yaml \
  --parameter-overrides EnableAccountEnforcement=true OrganizationId=o-xxxxxxxxxx

# 2. Invocation logging (there is no CloudFormation resource for it)
AWS_REGION=ap-southeast-2 ./native/enable-invocation-logging.sh

# 3. Organization policies (management account). Replace the placeholders in the JSON files first.
aws organizations enable-policy-type --root-id r-xxxx --policy-type BEDROCK_POLICY
aws organizations create-policy --type BEDROCK_POLICY --name aigov-bedrock-guardrail-enforcement \
  --description "Baseline guardrail enforcement" --content file://native/bedrock-policy.json
for f in native/scp/*.json; do
  aws organizations create-policy --type SERVICE_CONTROL_POLICY \
    --name "aigov-$(basename "$f" .json)" --description "AI governance Bedrock SCP" --content "file://$f"
done
aws organizations attach-policy --policy-id p-xxxxxxxx --target-id ou-xxxx-xxxxxxxx
```

Verify the result:

- `aws organizations describe-effective-policy --policy-type BEDROCK_POLICY --target-id <account>`
- `aws bedrock get-model-invocation-logging-configuration`

The native SCPs come as four separate files so you can adopt them one at a time. AWS allows at most 10 SCPs per target, including `FullAWSAccess`. To save slots, merge the files into one policy, as the Terraform does.

## Cross-Region inference caveats (AIG-06, AIG-08)

- **Allow-list ARNs.**
  - Foundation-model ARNs have no account segment (`arn:aws:bedrock:<region>::foundation-model/<id>`).
  - The allow-list uses a Region wildcard so that *geographic* inference profiles can reach their destination Regions.
  - When you call through an inference profile, approve **both** the profile ID (`approved_inference_profile_ids`) **and** the underlying model ID. A restriction on `foundation-model` alone does not cover calls made through an inference profile.
- **Region SCP.** Every destination Region of a geographic profile must be in `allowed_regions`. Cross-Region inference can route to Regions you have not enabled.
- **Global profiles.**
  - *Global* profiles (`global.*`) are evaluated with `aws:RequestedRegion = "unspecified"` against a Region-less foundation-model ARN (`arn:aws:bedrock:::foundation-model/<id>`).
  - They are blocked unless `allow_global_cross_region_inference = true`, which adds both of those values.
  - Global routing can process prompts in any commercial Region. Treat it as a cross-border transfer (AIG-18) before you enable it.
- **STANDARD guardrail tier.** The STANDARD tier also uses cross-Region guardrail inference (`cross_region_config`). Prompts may leave the source Region within the profile's geography. The default is CLASSIC.

## Region SCP note

`native/scp/restrict-regions.json` denies every Bedrock call outside the listed Regions, which also blocks **global** cross-Region inference profiles (their requests carry `aws:RequestedRegion = unspecified`). To allow global profiles, add `unspecified` to the list; the Terraform variant exposes this as a single switch.

## Unverified / known gaps

- **Automated Reasoning checks.** `aws_bedrock_guardrail` has no Automated Reasoning argument; CloudFormation has `AutomatedReasoningPolicyConfig`. Guardrails that use Automated Reasoning cannot be enforced at account or organization level, so this pack leaves them out.
- **No Terraform resource for account-level enforcement.**
  - The v6.68.0 provider schema has no resource for `PutEnforcedGuardrailConfiguration`. **UNVERIFIED** that one does not exist under another name.
  - Use `AWS::Bedrock::EnforcedGuardrailConfiguration` in `guardrail.yaml` instead. cfn-lint's bundled schema knows the type, and the template passes.
  - `AWS::Bedrock::EnforcedGuardrailConfiguration` and `AWS::Bedrock::ResourcePolicy` are not in the Cloud Control API supported-resources list, so `aws_cloudcontrolapi_resource` is not offered as an alternative.
- **Guardrail resource policy.** There is no Terraform resource for the guardrail's resource-based policy. Use `AWS::Bedrock::ResourcePolicy`, which is in `guardrail.yaml`.
- **Scope of the `bedrock:GuardrailIdentifier` SCP condition.**
  - It applies to InvokeModel, InvokeModelWithResponseStream, Converse and ConverseStream.
  - It does **not** cover RetrieveAndGenerate, InvokeAgent or InvokeInlineAgent. AWS advises against reusing the same role for those.
  - Input tags let a caller limit which prompt content the guardrail evaluates.
  - Requests without a guardrail, such as embedding calls, are denied unless the model is in `guardrail_exempt_resource_arns`.
- **Prompt attack filtering.**
  - With `InvokeModel`, prompt attacks are filtered only when the user input is wrapped in guardrail input tags.
  - The AWS docs show only input-side settings for `PROMPT_ATTACK`. `output_strength = "NONE"` follows that pattern. **UNVERIFIED** that `NONE` is mandatory.
  - CLASSIC tier does not detect prompt leakage.
- **No AWS Config managed rules.** There are none for "guardrail attached" or "invocation logging enabled". The only managed Bedrock rules cover knowledge-base data sources and AgentCore. Use a custom Config rule if you need continuous detection. The `AIG07AIG13ProtectBedrockInvocationLogging` SCP prevents tampering but does not detect it.
- **Invocation logging scope.**
  - Logging covers `bedrock-runtime` only. It does not cover `bedrock-mantle`.
  - `audioDataDeliveryEnabled` exists in the API and CLI but not in the Terraform resource, so audio payloads are not logged by the Terraform path.
- **Global inference ARN.** The Region-less foundation-model ARN used for global cross-Region inference is taken from AWS's IAM example. Its behaviour inside an SCP `NotResource` was not tested.
- **BEDROCK_POLICY maximum size.** The Organizations quotas page does not list one.
- **Audit Manager.** The "AWS Generative AI Best Practices Framework v2" can supply evidence, but Audit Manager is closed to new customers.
- **AIG-02 inventory.** This pack does not cover it. See `mapping.yaml` gaps.
