Automated AWS Infrastructure Deployment Pipeline

📌 Overview

In modern cloud environments, every infrastructure change must be carefully planned, reviewed, and explicitly approved before being applied to production. Unchecked deployments or direct manual modifications can lead to unintended downtime, security vulnerabilities, and state corruption.

This repository implements a team-oriented GitHub Actions pipeline for provisioning AWS cloud infrastructure with Terraform. By combining automated validation, temporary artifact storage, explicit human approval gates, and zero-trust secret management, this pipeline ensures that no infrastructure change reaches production without proper peer oversight.

🔐 Security & Secret Management: AWS access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) are never stored in the source code or workflow files, so the authentication to AWS is handled securely by injecting credentials stored in GitHub Repository Secrets into the workflow execution environment at runtime.

🏗️ Pipeline Architecture

The workflow consists of four sequential, interdependent jobs that are triggered automatically on every pull_request event:

[ Infrastructure Plan ] ──> [ Manual approval ] ──> [ Infrastructure Apply ] ──> [ Auto-Merge to main ]

1. Infrastructure Plan: This phase validates syntax and generates an execution plan without modifying production infrastructure. By running the commands terraform init and terraform plan -out=tfplan, the binary execution plan from Terraform is exported and uploaded as a workflow Artifact (tfplan) so it can be reused to apply the changes later on.

2. Manual Approval: It enforces human oversight and peer review prior to infrastructure modification. I used an issue/comment-based manual gate polling (trstringer/manual-approval) that generates a GitHub issue that asks to the required reviewer if the execution plan (tfplan) is approved or not. Only when the user comments "approved", this phase is successfully passed and the workflow continues on to the next stage; if the changes are not approved, the workflow run fails to continue and the changes are not applied.

3. Infrastructure Apply: Once the changes are approved, the execution plan uploaded in phase 1 is now downloaded and the corresponding AWS credentials are used to deploy the cloud infrastructure changes safely.

4. Auto-Merge to main: Once the infrastructure changes are successfully applied, the PR request is automatically merged to the main branch by using GitHub's CLI (gh pr merge --auto --squash) command, ensuring that it accurately reflects active infrastructure state.

🛠️ Problems faced & Key Architectural fixes

During the development and testing of this pipeline, several technical bottlenecks and runner execution challenges were encountered and resolved, here is the summary:

1. Ephemeral Runner File Loss & Execution Plan Mismatch
Problem: Subsequent jobs in GitHub Actions execute on fresh, isolated virtual machines. Running terraform apply on a separate runner failed or attempted to regenerate plans due to missing .tf configuration files and tfplan binaries.

Fix: Configured actions/checkout@v4 across planning and applying jobs to guarantee repository file consistency. Additionally, configured actions/upload-artifact@v4 and actions/download-artifact@v4 to pass the execution plan (tfplan) seamlessly between the Plan and Apply runner environments.

2. Exposure Risk of AWS Cloud Credentials
Problem: Hardcoding authentication credentials in workflow files introduces critical security risks and compliance violations.

Fix: Centralized AWS authentication using GitHub Encrypted Secrets (secrets.AWS_ACCESS_KEY_ID and secrets.AWS_SECRET_ACCESS_KEY). These are injected into environment variables only at job execution, enforcing zero-trust security standards.

3. Local vs. remote Terraform Version Mismatches
Problem: Discrepancies between the Terraform version used locally and the version running on GitHub runner images led to state file incompatibility and syntax parse errors.

Fix: Enforced exact version parity across all runner environments by pinning the CLI version in hashicorp/setup-terraform@v3 to match local development environments.

4. Unreviewed / Direct Infrastructure Deployments
Problem: Continuous integration pipelines that auto-apply changes on push risk deploying destructive modifications or unintended resource deletions without peer review.

Fix: Introduced an explicit manual approval gate (trstringer/manual-approval) between the Plan and Apply jobs. The pipeline now pauses execution and waits for an authorized user to review the generated plan before proceeding.

5. Stale Branches & Manual Branch Merge Friction
Problem: Requiring to manually merge Pull Requests after deployment creates branch drift between main and active cloud infrastructure, delaying delivery cycles.

Fix: Integrated GitHub CLI (gh pr merge --auto --squash) into the final pipeline job (Auto-Merge to main). Once terraform apply succeeds, the PR automatically merges into main, keeping the default branch fully synchronized with active infrastructure.

💼 Business & Organizational Impact

This pipeline's implementation addresses key infrastructure management challenges commonly faced by engineering teams:

1. Elimination of Unintended Production Outages
Problem: Direct execution of unreviewed Terraform applies can lead to accidental resource deletion or service downtime.

Solution: The explicit separation of Plan and Apply behind a mandatory Approval gate guarantees that every structural modification is peer-reviewed prior to deployment.

2. Prevention of Execution Drift
Problem: Differences between local environments or modifications made between planning and applying can introduce state file drift or lock mismatches.

Solution: Persisting the tfplan file across runner instances guarantees deterministic execution, that means the exact state calculated during the planning phase is what gets deployed.

3. Accelerated Delivery & Operational Velocity
Problem: Manual review processes combined with manual branch merging slow down deployment cycles and create git branch divergence.

Solution: Once approval is granted and the deployment succeeds, the PR automatically merges into main, reducing lead time for infrastructure changes while keeping the default branch synchronized.

4. Compliance, Auditability, and Governance
Problem: Tracking who approved and deployed specific infrastructure modifications can be difficult for compliance audits.

Solution: Native GitHub Action logs, PR comments, and audit trails capture every plan output, reviewer approval, and deployment status automatically.


