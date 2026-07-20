# Azure Terraform Pipeline Guide

## 🚀 Pipeline Workflow

This document explains how the environment-friendly CI/CD pipeline works end-to-end.

---

## Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SELECT ENVIRONMENT (dev/test/prod)                       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. CI STAGE: Plan                                            │
│    • Checkout code                                           │
│    • Install Terraform                                       │
│    • terraform init (with env-specific backend key)          │
│    • terraform fmt -check                                    │
│    • terraform validate                                      │
│    • terraform plan -var-file=environments/ENV.tfvars        │
│    • Publish plan as artifact                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
        ┌────────────────┐
        │ Plan Succeeds? │
        └────────┬───────┘
                 │
      ┌──────────┴──────────┐
      │                     │
      ▼                     ▼
   YES (Dev/Test)      NO (Prod)
      │                     │
      ▼                     ▼
┌──────────────┐    ┌──────────────────┐
│ CD Stage:    │    │ Approval Gate    │
│ Auto-Apply   │    │ (Manual Review)  │
│ (Immediate)  │    └────────┬─────────┘
└──────────────┘             │
                             ▼
                        ┌──────────────┐
                        │ Approved?    │
                        └────────┬─────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                  YES                        NO
                    │                         │
                    ▼                         ▼
              ┌──────────────┐        ┌──────────────┐
              │ CD Stage:    │        │ REJECTED     │
              │ terraform    │        │ (No Deploy)  │
              │ apply        │        └──────────────┘
              └──────────────┘
```

---

## Stages Explained

### **Stage 1: Plan (CI)**
**Purpose:** Validate infrastructure changes without applying them

| Component | Details |
|-----------|---------|
| **Trigger** | When pushing to `main` branch |
| **Environment** | Selected via pipeline parameter |
| **Actions** | Terraform init/validate/plan |
| **Output** | Plan file artifact (e.g., `tfplan-dev`) |
| **Duration** | ~2-5 minutes |

**Example output:**
```
terraform plan -var-file="environments/dev.tfvars" -out=tfplan-dev
```

---

### **Stage 2: Approval Gate (Prod Only)**
**Purpose:** Require manual review before production deployment

| Scenario | Behavior |
|----------|----------|
| Dev/Test | ✅ Skipped - proceeds to Apply immediately |
| Prod | ⏸️ Paused - waits for human approval (24h timeout) |

---

### **Stage 3: Apply (CD)**
**Purpose:** Create/update infrastructure in Azure

| Environment | Auto-Apply? | Approval Required? |
|-------------|------------|-------------------|
| **dev** | ✅ Yes | No |
| **test** | ✅ Yes | No |
| **prod** | ❌ No | Yes (manual) |

**What happens:**
```bash
terraform init -backend-config="key=ENV.tfstate"
terraform apply -auto-approve tfplan-ENV
```

---

## Environment Configuration

### Dev Environment
- **tfvars file:** `environments/dev.tfvars`
- **Backend state:** `dev.tfstate`
- **VM Size:** `Standard_B2s` (small, cost-optimized)
- **Auto-deploy:** Yes
- **Use case:** Development & testing

### Test Environment
- **tfvars file:** `environments/test.tfvars`
- **Backend state:** `test.tfstate`
- **VM Size:** `Standard_D2s_v3` (medium, staging-like)
- **Auto-deploy:** Yes
- **Use case:** Staging & integration testing

### Prod Environment
- **tfvars file:** `environments/prod.tfvars`
- **Backend state:** `prod.tfstate`
- **VM Size:** `Standard_D2alds_v7` (large, performance)
- **Auto-deploy:** No - requires approval
- **Use case:** Production workloads

---

## How to Queue the Pipeline

### Step 1: Push Code to Main
```bash
git add .
git commit -m "feat: infrastructure changes"
git push origin main
```

### Step 2: Queue Pipeline in Azure DevOps
1. Go to **Pipelines** → **azure_simple_pipeline**
2. Click **Queue new build**
3. Select environment: **dev**, **test**, or **prod**
4. Click **Queue**

### Step 3: Monitor Execution
- View **Plan stage** → See what will change
- For prod, review and **Approve** in the Approval Gate
- View **Apply stage** → See resources being created/updated

---

## State File Management

All environments share the same backend storage but keep separate state files:

| Environment | State File Path |
|-------------|-----------------|
| dev | `tfstate/dev.tfstate` |
| test | `tfstate/test.tfstate` |
| prod | `tfstate/prod.tfstate` |

**Storage Location:** Azure Storage Account `tfstateab5f887b1`

---

## Troubleshooting

### Issue: Plan fails on validation
**Check:**
- Terraform syntax: `terraform fmt -check`
- Variable file: `environments/ENV.tfvars` exists and has valid values
- Backend config: `backend.tf` is correctly configured

### Issue: Approval gate times out
**Note:** Approval waits for 24 hours before timing out. Check email for approval notifications.

### Issue: Apply fails after approval
**Check:**
- Azure authentication is valid
- Resource quotas aren't exceeded
- Network/security group rules allow the changes

---

## Key Features

✅ **Environment Isolation** - Each environment has separate state and configuration
✅ **Approval Gates** - Production requires manual approval before deployment
✅ **Plan Artifacts** - All plans are saved for audit trail
✅ **Dynamic Configuration** - Backend key and tfvars change per environment
✅ **Cost Optimization** - Dev uses smaller (cheaper) resources than prod

---

## Next Steps

1. **Populate tfvars files** with your actual Azure resources
2. **Test with dev** first - queue pipeline and select `dev`
3. **Review plan output** - verify changes before they're applied
4. **Promote to prod** - once satisfied, queue with `prod` environment

