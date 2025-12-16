# gcp-capstone
Repo for Terraform Docker CI/CD and GKE

# Bootstrap Module

**⚠️ READ THIS FIRST - THIS MODULE IS SPECIAL**

This directory contains the **irreplaceable** foundation resources for your entire GCP infrastructure. Think of it as the foundation of a house: if you destroy this, everything else collapses. **These resources are designed to be created once and never destroyed.**

## What This Module Creates

1. **Terraform State Bucket (GCS)**: The single source of truth for all Terraform state files
   - Versioning enabled: Your "undo button" for state corruption
   - Uniform bucket-level access: Prevents accidental public exposure
   - Lifecycle policy: Automatically cleans up old versions after 5 newer versions exist

2. **Required GCP API Enablements**: Ensures critical APIs are active before other modules run
   - `compute.googleapis.com` (VPC, GKE)
   - `storage-component.googleapis.com` (GCS)
   - `container.googleapis.com` (GKE)
   - `cloudresourcemanager.googleapis.com` (Project management)

## Why Bootstrap is Separate

### The "Chicken or Egg" Problem
You can't store Terraform state in a bucket that doesn't exist yet. If we put the state bucket in the same Terraform configuration that uses it, Terraform would fail on the first run because it can't find the backend.

### The Blast Radius Principle
If you accidentally corrupt or delete your main infrastructure's state, you can still recover because **this bucket lives in its own isolated state file** (usually managed locally). This is your insurance policy.

### The Senior DevOps Approach
**Juniors** put everything in one Terraform stack and wonder why they can't recover from state file corruption. **Seniors** bootstrap permanent resources manually (or with isolated state), then build everything else on top.

## How to Use This Module (Follow Exactly)

### Step 1: Prepare Your Values File

Create `bootstrap/values.dev.tfvars` (fill `EMPTY VALUES`):

```bash
cat &gt; bootstrap/values.dev.tfvars &lt;&lt;EOF
project_id          = ""
region              = "us-central1"
state_bucket_name   = ""
EOF
