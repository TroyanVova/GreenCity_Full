
## Branches

### `manual_set_up`
Manual deployment without Docker. The project runs on 4 separate VMs on Proxmox (`vm-db`, `vm-backcore`, `vm-backuser`, `vm-frontend`, Ubuntu Server 22.04): PostgreSQL is installed directly on `vm-db`, the `backcore` and `backuser` backends are built with Maven and run as `systemd` services, and the frontend is built with Angular and served through Nginx. Every step is done manually, one at a time.

### `docker`
Basic deployment using Docker Compose. The whole system (`db`, `core`, `user`, `frontend`) runs on a single VM with one `docker compose up` command.

### `docker-load-balancer`
Builds on the `docker` branch: adds Nginx as a Load Balancer (a single entry point to `core`/`user`) and Redis as an application-level cache (Spring `@Cacheable` in `core`/`user`, with a fallback to PostgreSQL). This prepares the infrastructure for future horizontal scaling.

### `jenkins`
CI/CD based on Jenkins: a master + agent setup on Proxmox, connected to the GitHub repository. Includes a private Docker registry, centralized monitoring (Prometheus + Loki + Grafana) with Discord alerts, automatic code-quality checks with SonarCloud, a job that deploys to a fixed staging VM on every push (through an instant GitHub webhook), and a separate on-demand job that creates a new Proxmox VM via Ansible and deploys the full stack to it.

### `Ansible` 
Automates the `manual_set_up` branch with Ansible playbooks: creating VMs on Proxmox and installing and configuring all services without manual steps.

### `cloud`
Deploys the app on AWS instead of Proxmox: a self-managed `k3s` cluster on EC2 (chosen over EKS/ECS for cost, while still using Kubernetes), behind an Application Load Balancer with path-based routing, backed by an RDS Postgres database. Includes its own Jenkins pipeline that builds and pushes images to ECR and deploys them to the cluster with `kubectl`. Provisioned with Terraform (`infra/`) and Kubernetes manifests (`k8s/`), fully independent from the Proxmox deployment tracks.

---

Detailed deployment instructions for each approach are in the branch.
