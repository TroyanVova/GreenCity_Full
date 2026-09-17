# GreenCity — AWS Cloud Deployment (Terraform + k3s + Jenkins)

This is a step-by-step guide to deploy GreenCity (`frontend`, `backcore`, `backuser`, PostgreSQL, Redis) on AWS. It uses Terraform to build the infrastructure, a self-managed `k3s` Kubernetes cluster on EC2, and a Jenkins pipeline to build and deploy the app.

> For architecture diagrams, request routing details, and a list of real bugs found during this deployment, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

---

## 1. What You Need Before You Start

| Requirement | Notes |
|---|---|
| AWS account | With permission to create VPC, EC2, ALB, RDS, ECR, IAM resources |
| AWS CLI | Installed and configured with your access keys (`aws configure`) |
| Terraform | Version `>= 1.5.0` |
| An EC2 key pair | Needed for SSH access to the cluster nodes |
| A running Jenkins server | This guide assumes Jenkins already exists (controller + at least one agent). See section 5 for what the agent needs. |
| Your public IP address | You will allow SSH only from this IP |

---

## 2. Build the AWS Infrastructure (Terraform)

```bash
git clone -b cloud <your-repo-url> GreenCity_Full
cd GreenCity_Full/infra
```

Copy the example variables file and fill in your own values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and set these:

| Variable | What to put |
|---|---|
| `aws_region` | AWS region, e.g. `us-east-1` |
| `project_name` | Short name used as a prefix for every resource, e.g. `greencity` |
| `environment` | Tag value, e.g. `demo` |
| `ssh_allowed_cidr` | Your public IP with `/32`, e.g. `"203.0.113.10/32"`. Find your IP at [whatismyip.com](https://www.whatismyip.com/) |
| `db_password` | A strong password for the RDS master user |

Other variables in `variables.tf` (instance type, VPC CIDR, DB size, etc.) already have safe defaults. You do not need to change them for a demo deployment.

Now build the infrastructure:

```bash
terraform init
terraform plan
terraform apply
```

Type `yes` when asked. This takes some time — it creates the VPC, the load balancer, the RDS database, and 3 EC2 instances. After the instances start, they still need a few more minutes to install `k3s` and join the cluster.

When it finishes, save these values — you will need them later:

```bash
terraform output -raw k3s_server_public_ip
terraform output -raw alb_dns_name
terraform output -raw db_endpoint
terraform output ecr_repository_urls
```

---

## 3. Check the Cluster Is Ready

Wait about 5 minutes after `terraform apply` finishes, then connect to the server node by SSH:

```bash
ssh -i <path-to-your-key> ec2-user@<k3s_server_public_ip>
sudo k3s kubectl get nodes
```

You should see 3 nodes, all with status `Ready`. If you see fewer than 3, or a node stuck in `NotReady`, wait a bit longer — the agent nodes join the server after it is fully up.

While you are connected, set up the base Kubernetes objects (only needed once, the first time):

```bash
sudo k3s kubectl apply -f k8s/namespace.yaml
sudo k3s kubectl apply -f k8s/rbac-jenkins.yaml
```

The first command creates the `greencity` namespace. The second creates a dedicated Kubernetes user (`jenkins-deployer`) with only the permissions Jenkins actually needs — not full admin access.

---

## 4. Build a `kubeconfig` File for Jenkins

Jenkins needs its own `kubeconfig` file to talk to the cluster — using the limited `jenkins-deployer` account from step 3, not your personal admin access.

Get the token for that account (run this on the server node, over SSH):

```bash
sudo k3s kubectl -n greencity get secret jenkins-deployer-token -o jsonpath='{.data.token}' | base64 -d
```

Copy the long token string it prints. Now, on the Jenkins agent machine, create the file `/home/jenkins-agent/.kube/greencity-cloud` with this content:

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: greencity-cloud
    cluster:
      server: https://127.0.0.1:6443
      insecure-skip-tls-verify: true
contexts:
  - name: greencity-cloud
    context:
      cluster: greencity-cloud
      namespace: greencity
      user: jenkins-deployer
current-context: greencity-cloud
users:
  - name: jenkins-deployer
    user:
      token: "<PASTE THE TOKEN HERE>"
```

Note: the server address is `127.0.0.1:6443`, not the real cluster IP. This is on purpose — the Jenkins pipeline opens an SSH tunnel to the server node before it runs any `kubectl` command (see the pipeline stages in section 7), so from Jenkins's point of view, the cluster API is reachable on `localhost`. `insecure-skip-tls-verify: true` keeps this simple for a demo project; it is fine because this connection only exists inside the SSH tunnel.

---

## 5. Prepare the Jenkins Agent

On the Jenkins agent that will run this pipeline, install:

```bash
sudo apt update
sudo apt install -y docker.io awscli
# install kubectl — see https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```

Add an AWS CLI profile named `greencity-cloud` with keys that can push images to ECR and call `sts get-caller-identity`:

```bash
aws configure --profile greencity-cloud
```

Copy your EC2 SSH key to the agent, at the exact path the pipeline expects:

```bash
# on the agent
mkdir -p /home/jenkins-agent/.ssh
# copy the same key file you used for ssh_allowed_cidr / ec2_key_name
cp <your-key>.pem /home/jenkins-agent/.ssh/greencity-k3s
chmod 600 /home/jenkins-agent/.ssh/greencity-k3s
```

---

## 6. Set Up Jenkins Credentials

In Jenkins, go to **Manage Jenkins → Credentials**, and add these as **Secret text**:

| Credential ID | Value |
|---|---|
| `gc-cloud-db-password` | The same password you put in `db_password` in `terraform.tfvars` |
| `gc-cloud-redis-password` | A password for Redis (your choice — used only inside the cluster) |
| `gc-cloud-email-address` | The Gmail address used to send verification emails |
| `gc-cloud-email-password` | The Gmail **App Password** (not your normal Gmail password) for that address |

---

## 7. Create the Jenkins Job

1. New Item → Pipeline.
2. Definition: **"Pipeline script from SCM"**.
3. SCM: Git, point it at your repository, branch `cloud`.
4. Script path: `Jenkinsfile` (it is at the repo root).
5. Save.

The pipeline has 3 build parameters, filled in by hand each time you run it, using the `terraform output` values from step 2:

| Parameter | Value |
|---|---|
| `SERVER_IP` | `terraform output -raw k3s_server_public_ip` |
| `ALB_DNS` | `terraform output -raw alb_dns_name` |
| `DB_ENDPOINT` | `terraform output -raw db_endpoint` |

Click **Build with Parameters**, fill in the 3 values, and run it.

The pipeline does this, in order: checkout the code → build and push the 3 Docker images to ECR → open an SSH tunnel to the cluster → update the Kubernetes secret with your DB/Redis/email credentials → apply all the `k8s/*.yaml` files and roll out the new images → run a health check against the public ALB address.

---

## 8. Check the Deployment

```bash
# frontend
curl -i http://<ALB_DNS>/

# backcore health
curl -i http://<ALB_DNS>/core/actuator/health

# backuser health
curl -i http://<ALB_DNS>/user/actuator/health
```

Both health checks should return `{"status":"UP"}`. Open `http://<ALB_DNS>/` in a browser — the GreenCity site should load, and sign-up / login should work.

---

## 9. Keep the ECR Login Working

The token AWS uses to pull Docker images from ECR only lasts 12 hours. Apply this once, and it refreshes itself automatically every 6 hours after that — you do not need to do anything else:

```bash
sudo k3s kubectl apply -f k8s/ecr-refresh-cronjob.yaml
```

See [`ARCHITECTURE.md`](./ARCHITECTURE.md) for a full explanation of why this is needed.

---

## 10. Things to Check If Something Goes Wrong

- **Pods stuck in `ImagePullBackOff`.** Most likely the ECR pull token expired and the CronJob from step 9 is not applied yet, or has not run for the first time. Check it with `sudo k3s kubectl -n greencity get cronjob,job`.
- **Pods stuck in `CrashLoopBackOff` right after deploy.** Check the pod logs: `sudo k3s kubectl -n greencity logs deployment/backcore`. A common cause is the app not able to reach RDS — double-check the `DB_ENDPOINT` parameter you gave the pipeline, and that the `db-sg` security group allows traffic from `node-sg`.
- **Health check curl commands return 404.** This usually means `SERVER_SERVLET_CONTEXT_PATH` is missing from `k8s/backcore.yaml` / `k8s/backuser.yaml` — the ALB does not rewrite paths, so each app must answer on `/core` / `/user` itself.
- **Agent nodes never show up in `kubectl get nodes`.** Give it more time — agents wait for the join token in SSM Parameter Store, which the server only writes after `k3s` fully starts. If it still does not join after 10+ minutes, SSH into an agent and check `sudo journalctl -u k3s-agent`.
- **Jenkins `kubectl` commands fail with a connection error.** Check that the SSH tunnel stage actually succeeded, and that the `kubeconfig` file in step 4 points at `127.0.0.1:6443`, not the real server IP.
- **Login/verification emails do not arrive.** Check the Gmail App Password credential is correct, and that the `backuser` pod was restarted after the last time you changed the email credentials — Kubernetes does not reload a `Secret` into an already-running pod automatically (`sudo k3s kubectl -n greencity rollout restart deployment/backuser`).

---

## 11. Tearing It Down

To remove everything and stop paying for it:

```bash
cd infra
terraform destroy
```

Type `yes` when asked. This removes the EC2 instances, the ALB, the RDS database, and every other resource Terraform created. The Docker images already pushed to ECR are **not** removed automatically — delete the ECR repositories by hand in the AWS Console if you want a completely clean account.
