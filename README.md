Automated Terraform Infrastructure Pipeline (CI/CD)
This repository contains an automated GitHub Actions CI/CD pipeline designed for provisioning and managing cloud infrastructure using Terraform. The workflow automates continuous integration, manual peer-review gates, state/lock consistency, and automated Pull Request merging upon deployment verification.

🏗️ Pipeline Architecture
The workflow consists of four sequential, interdependent jobs triggered automatically on every pull_request event:

[ Infrastructure Plan ] ──> [ approval ] ──> [ Infrastructure Apply ] ──> [ Enable Auto-Merge ]
1. Infrastructure Plan (Infrastructure Plan)
Purpose: Validates syntax and generates an execution plan without modifying production infrastructure.

Mechanism: Runs terraform init and terraform plan -out=tfplan.

Artifact Management: Uploads both the binary execution plan (tfplan) and dependency lock file (.terraform.lock.hcl) as workflow artifacts to ensure consistency across ephemeral runner environments.

2. Manual Approval Gate (approval)
Purpose: Enforces human oversight and peer review prior to infrastructure modification.

Mechanism: Utilizes issue/comment-based manual gate polling (trstringer/manual-approval).

Governance: Halts pipeline execution until designated engineers review the proposed changes and comment approved.

3. Infrastructure Apply (Infrastructure Apply)
Purpose: Safely provisions cloud resource changes.

Mechanism: Downloads the exact tfplan and .terraform.lock.hcl artifacts uploaded during the planning phase and executes terraform apply -auto-approve tfplan.

Safety: Guarantees that only the precise, peer-reviewed plan is executed, preventing drift or concurrency races.

4. Automated Merging (Enable Auto-Merge)
Purpose: Eliminates manual git overhead and ensures the primary branch accurately reflects active infrastructure state.

Mechanism: Leverages GitHub's CLI (gh pr merge --auto --squash) to merge the Pull Request into main automatically after deployment confirmation.

💼 Business & Organizational Impact
Implementing this pipeline addresses key infrastructure management challenges commonly faced by engineering teams:

1. Elimination of Unintended Production Outages
Problem: Direct execution of unreviewed Terraform applies can lead to accidental resource deletion or service downtime.

Solution: The explicit separation of Plan and Apply behind a mandatory Approval gate guarantees that every structural modification is peer-reviewed prior to deployment.

2. Prevention of Execution Drift & Race Conditions
Problem: Differences between developer local environments or modifications made between planning and applying can introduce state file drift or lock mismatches.

Solution: Persisting the tfplan and .terraform.lock.hcl files across runner instances guarantees deterministic execution: the exact state calculated during the planning phase is what gets deployed.

3. Accelerated Delivery & Operational Velocity
Problem: Manual review processes combined with manual branch merging slow down deployment cycles and create git branch divergence.

Solution: Once approval is granted and the deployment succeeds, the PR automatically merges into main, reducing lead time for infrastructure changes while keeping the default branch synchronized.

4. Compliance, Auditability, and Governance
Problem: Tracking who approved and deployed specific infrastructure modifications can be difficult for compliance audits.

Solution: Native GitHub Action logs, PR comments, and audit trails capture every plan output, reviewer approval, and deployment status automatically.
