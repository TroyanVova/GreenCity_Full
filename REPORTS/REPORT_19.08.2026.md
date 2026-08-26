DevOps Report

General Information
Reporting period: 12/08/2026 – 19/08/2026
Report date: 19/08/2026
Author: Volodymyr
Project: GreenCity (MVP)
Goal: Add Load Balancing (Nginx) and Redis caching on top of the already-deployed GreenCity stack (`db`, `core`, `user`, `frontend`) running via Docker Compose, and build a CI/CD pipeline on Jenkins (Proxmox) - on-demand provisioning of a full environment (VM + entire stack) with a single command.


Goals
Main goal: Introduce Nginx as the single entry point for the backends (`core`/`user`) instead of direct port exposure, and replace the local in-memory cache (Caffeine) with a shared Redis cache at the application level (cache-aside: check Redis first, fall back to Postgres on a miss).
Related goals:
Document the process as a step-by-step markdown guide for the team, including the real problems found during deployment.
Prepare the architecture for future horizontal scaling of `core`/`user` without reworking the rest of the configuration.
Automate build and deployment (CI/CD) via Jenkins - from a GitHub push to a fully working environment, including on-demand infrastructure provisioning in Proxmox via a single command.


Completed Tasks
Task | Status | Owner | Completion Date | Notes
1 Analysis of the existing code (`pom.xml`, `application-docker.properties`, `SecurityConfig.java`, frontend `nginx.conf`) to design a solution tailored to this specific stack - Completed - Volodymyr - 12/08/2026 - Found that both backends already cache locally via Caffeine, and `backuser` does so without an explicit dependency in `pom.xml`
2 Added Redis as an application-level cache (`spring-boot-starter-data-redis`, `CacheConfig.java` with JSON serialization via `GenericJackson2JsonRedisSerializer`) in `backcore` and `backuser` - Completed - Volodymyr - 12/08/2026 - `spring.cache.type=redis`; the `@Cacheable` logic in the services was not changed - only the cache provider
3 Added Spring Boot Actuator (`/actuator/health`) for container healthchecks - Completed - Volodymyr - 13/08/2026 - Required an additional allowance in `SecurityConfig.java` and disabling irrelevant health indicators (RabbitMQ, Mail)
4 Wrote the Nginx load balancer configuration (`lb/nginx.conf`) - reverse proxy on ports 8080/8060 - Completed - Volodymyr - 13/08/2026 - `upstream` blocks are ready for adding replicas without rewriting the rest of the config
5 Updated `docker-compose.yml`: new services `redis` and `lb`; `core`/`user` no longer publish ports directly - Completed - Volodymyr - 14/08/2026- External ports 8080/8060 remained unchanged - no edits to `environment.prod.ts` were needed
6 Deployed the updated stack on the VM and fixed issues found during the real run - Completed - Volodymyr - 14/08/2026 - Details in the "Problems and Solutions" section
7 Verified cache operation via a real API call and `redis-cli` - Completed - Volodymyr - 15/08/2026 - Confirmed by keys appearing in Redis after calling `/habit/statistic/todayStatisticsForAllHabitItems`
8 Deployed the Jenkins infrastructure on Proxmox: a separate `jenkins-master` VM (controller, UI/credentials/orchestration) and a separate `jenkins-agent` VM (worker with Maven, Node.js, Docker - all heavy build work moved off the controller- Completed - Volodymyr - 16/08/2026 - Set 0 executors on the built-in node so that no stage could accidentally run on the controller
9 Developed an on-demand provisioning pipeline: a parameterized Jenkins job (`BRANCH`/`VMID`/`VM_IP`) that, via Ansible (`community.general.proxmox_kvm`), idempotently provisions a VM in Proxmox from a ready-made Docker template and deploys the full stack (`db`, `core`, `user`, `redis`, `lb`, `frontend`) from the specified branch - Completed- Volodymyr - 18/08/2026 - Per the user's decisions: provisioning via Ansible (not Terraform or a raw API), Redis included in the stack, VMID/IP/BRANCH as job parameters, allowing several environments to run in parallel (e.g. for different PRs)
10 End-to-end debugging of the on-demand pipeline on a real Proxmox cluster - sequentially identifying and fixing authentication errors, access-permission issues, variable-escaping problems in the Jenkinsfile, and target-VM resource constraints - Completed - Volodymyr - 19/08/2026 - Details in the "Problems and Solutions" section


Results
Actions taken:
Designed an architecture in which Redis is used exclusively as an application-level cache at the Spring layer (`@Cacheable`), not at the Nginx layer - the load balancer only distributes HTTP traffic and does not talk to Redis directly.
Added a `redis` service (image `redis:7-alpine`, password via `.env`, no persistence - `--save "" --appendonly no`, since it is a pure cache) and an `lb` service (image `nginx:1.25-alpine`) to `docker-compose.yml`.
`core` and `user` switched from `ports` to `expose` - external access on 8080/8060 now goes only through `lb`; internal `core ↔ user` calls remain direct, since only a single instance of each service is currently running.
Wrote `CacheConfig.java` for both backends, overriding `RedisCacheManager`'s default Java serialization with JSON - otherwise DTOs that don't implement `Serializable` would fail with a `SerializationException`.
Provisioned a separate `jenkins-master`/`jenkins-agent` VM pair on Proxmox.
Designed and implemented a parameterized on-demand pipeline that combines Ansible-based VM provisioning in Proxmox (idempotent "does it exist" check) with a subsequent full Docker Compose stack deployment - from a single Jenkins command to a fully working environment.
Achieved results:
The stack comes up with a single command (`docker compose --env-file .env up -d`) — 6 containers: `db`, `redis`, `core`, `user`, `lb`, `frontend` - all `healthy`.
Verified end-to-end: calling a real endpoint (`/habit/statistic/todayStatisticsForAllHabitItems`) results in a corresponding key appearing in Redis (`redis-cli keys '*'`), confirming the cache works per the "Redis first, then Postgres on a miss" scheme.
Confirmed with a working run: with a single command in Jenkins (specifying branch, VMID, and IP), the GreenCity environment comes up from scratch - from no VM at all to a fully working `lb`+`backcore`+`backuser`+`frontend`+`db`+`redis` stack.


Problems and Solutions
Problem | Solution | Status
1 The `redis` service healthcheck was constantly `unhealthy` (`NOAUTH Authentication required`) - The password was only substituted into `command:` at the host-side compose-file parsing stage - inside the container, the variable used by the healthcheck was empty; added an explicit `environment: REDIS_PASSWORD` block to the `redis` service - Completed
2 `core`/`user` were constantly `unhealthy`, even though the logs showed the application starting successfully - `/actuator/health` didn't match any `permitAll()` rule in `SecurityConfig.java` and fell through to the final `.anyRequest().hasAnyRole(ADMIN)` (401/403); added `.requestMatchers("/actuator/health").permitAll()` in both `SecurityConfig.java` files - Completed
3 After fixing #2 - a new failure, logs showed `ConnectException: Connection refused` to RabbitMQ - Actuator automatically registered `RabbitHealthIndicator` because `spring-rabbit` is a dependency in both backends' `service/pom.xml`, even though RabbitMQ is not part of the stack; disabled `management.health.rabbit.enabled=false` and `management.health.mail.enabled=false` - Completed
4 Cache verification (`redis-cli keys '*'`) consistently showed an empty result after the test request - The endpoint chosen for testing (`/econews/newest`) returned `404 Eco news haven't been found` - there is no data in the database, and Spring does not cache the result of a method that threw an exception; this was not a configuration error but an incorrect choice of test endpoint. Switched to a different endpoint (`/habit/statistic/todayStatisticsForAllHabitItems`) that always returns a value even on an empty result set - Completed
5 `Invalid IPv6 URL`, then later `NameResolutionError` for host "https" when the Ansible module `community.general.proxmox_kvm` accessed the Proxmox API - The `api_host` parameter only accepts a bare IP/hostname - no `https://` scheme and no `:8006` port (the port has its own separate parameter, `api_port`); a full URL in that field caused a duplicated port that the URL parser incorrectly interpreted as an invalid IPv6 literal - Completed
6 `401 Unauthorized` when accessing the Proxmox API with a correct host: first the token literally contained `$PVE_TOKEN_ID`, then a duplicated `ci-provisioner@pve!ci-provisioner@pve` - Cause #1: single quotes in a Groovy string in the `Jenkinsfile` prevented bash from substituting the variable's value (`'$VAR'` instead of `"$VAR"`); Cause #2: the `api_token_id` field was passed the full token name including the username, even though the module itself prepends the username (`api_user`). Fixed both: double quotes for substitution in the Jenkinsfile, and only the short token name (`jenkins`) in `api_token_id` - Completed
7 `401 Unauthorized: no such user ('ci-provisioner@pve')` - even though the user appeared to already exist - In the Proxmox UI, the user had been created as `ci-provisioner@pve@pam` - the realm was typed into the username field as well, while the dropdown was left at the default `pam`. Deleted the incorrect account, recreated `ci-provisioner@pve` under the `pve` realm, and reassigned the token and ACLs to the new user - Completed
8 `"VM with name = 9002 does not exist in cluster"` during cloning, even though a VM with that VMID actually exists - The `clone` parameter of the `proxmox_kvm` module expects the template's **name**, not its VMID; replaced it with a variable containing the actual template name (`for-jenkins`) - Completed
9 Sequential `403 Forbidden` errors during cloning: first `Datastore.AllocateSpace` on `/storage/local-lvm`, then `SDN.Use` on `/sdn/zones/localnetwork/vmbr0`; also a rejected `VM.Monitor` privilege when updating the ACL role - Proxmox permissions are not automatically inherited from the VM pool down to storage or network SDN objects; added separate ACL entries on `/storage/local-lvm` and `/sdn/zones/...`, and removed the `VM.Monitor` privilege (unsupported in this Proxmox version) from the role - Completed
10 On the target VM: `Sorry, user deployer is not allowed to execute '/usr/bin/mkdir ...'` - The SSH session was already running as `deployer`, while commands were issued via `sudo -u deployer` (sudo-ing into oneself) - `sudoers` only covered git/docker, not mkdir. Instead of extending `sudoers`, moved the deploy directory into `deployer`'s home folder (`/home/deployer/greencity`), where sudo isn't needed at all - Completed
11 `REMOTE HOST IDENTIFICATION HAS CHANGED` on every repeat SSH connection - The on-demand VM is recreated on the same IP with a new SSH host key each time; `known_hosts` on `jenkins-agent` still had the old key cached. Added `-o UserKnownHostsFile=/dev/null` to all ssh/scp calls in the Jenkinsfile- Completed
12 `fatal: could not read Username for 'https://github.com'`, and after the first fix - `bash: line 6: org: No such file or directory` - A private repository with no credentials couldn't complete non-interactive authentication - added a Personal Access Token (`github-greencity`) substitution directly into the remote repository URL; the second error was an unreplaced `<org>` placeholder in `REPO_URL`, with bash interpreting the `<`/`>` characters as input/output redirection - Completed
13 `ng build --prod` failed with `FatalProcessOutOfMemory`/`Aborted (core dumped)` during `docker compose build` on the target VM — The VM template only had 4 GB of RAM - not enough for a simultaneous Maven and Angular build (the same requirement as in the base Docker deployment: 8 GB recommended). Increased the template's RAM to 8 GB; additionally recommended `--max-old-space-size` for Node in the frontend Dockerfile as a safeguard - Completed


Next Steps
Scale `core`/`user` to multiple replicas once real load appears - the guide already includes a ready-made section ("If real scaling is needed later"), including the nuance around `lb` network aliases for balancing internal `core ↔ user` traffic.
For WebSocket connections (`/socket`) once a second `core` replica is added - enable `ip_hash` in `lb/nginx.conf`, since the STOMP broker is currently in-memory and does not share state between instances.
Consider container monitoring (Prometheus + cAdvisor) - still relevant from the previous report.
If needed - remove `spring-rabbit` from the dependencies if RabbitMQ is ultimately not used in the project, instead of just disabling the health indicator.
Implement a symmetric `GreenCity-OnDemand-Destroy` job to tear down on-demand environments (`VMID` parameter -> `proxmox_kvm: state=absent`), if environments should self-destruct after a PR is merged/closed.
Move from a PAT embedded in the URL to a one-shot `git -c http.extraheader="AUTHORIZATION: bearer <token>" fetch` for the private repository - removing the token from `.git/config`, which currently remains in plaintext on the target VMs between runs.


Tools and Technologies Used
Nginx: reverse proxy / load balancer in front of `core` and `user`, the single external entry point on ports 8080/8060.
Redis: distributed application-level cache (Spring Cache abstraction, `@Cacheable`), replacing the local Caffeine cache.
Spring Boot Actuator: health indicators for Docker healthchecks, with explicit disabling of irrelevant indicators (RabbitMQ, Mail).
Docker / Docker Compose: orchestration of the new services (`redis`, `lb`) on top of the existing `db`/`core`/`user`/`frontend` stack.
Jenkins: CI/CD orchestration on separate `jenkins-master` (controller) and `jenkins-agent` (worker) VMs, Multibranch Pipeline, parameterized jobs.
Ansible (`community.general.proxmox_kvm`): idempotent VM provisioning in Proxmox via the API - existence check, cloning from a cloud-init template, static IP configuration.
Proxmox VE API / ACL: access tokens, roles, and permissions on VM pools, storage, and SDN networks for the automation service account.
GitHub: Personal Access Token for authenticating Jenkins and the target VMs against the private repository.


Comments and Conclusions
The deployment confirmed a scenario typical of DevOps work: most of the real problems turned out not to be in the architectural decision itself, but in side effects of adding Actuator (health indicators for services that aren't part of the stack) and in existing, previously unnoticed security settings (`SecurityConfig` with a default deny-all). None of the three problems found were visible from a static code review alone - all were confirmed only through real container logs. The key architectural decision - keeping the cache logic ("Redis, then DB") at the Spring layer rather than the Nginx layer - proved justified: the load balancer stayed a simple reverse proxy, and adding Redis did not touch the services' business logic.
Building the on-demand CI/CD pipeline turned out to be a textbook example of the same pattern: none of the nine real obstacles encountered while debugging Jenkins/Ansible/Proxmox were visible in advance - all were discovered only through repeated runs against a live Proxmox cluster. Most of them were not architectural errors, but mismatches between how the API/CLI parameters were *expected* to work (full Token ID, VMID instead of template name, ACLs that seemingly inherit from the pool) and how they actually behave in Proxmox. This confirms the value of a step-by-step guide with a "common problems" section - the next deployment on a different cluster will bypass these already-documented pitfalls immediately, instead of working through the same chain of errors again.


Appendices and Resources
Deployment guide: I'll add a link to Git later
Previous report (base deployment): I'll add a link to Git later
Base deployment guide: I'll add a link to Git later
CI/CD guide: I'll add a link to Git later
On-demand provisioning guide: I'll add a link to Git later
Nginx upstream module documentation: https://nginx.org/en/docs/http/ngx_http_upstream_module.html
Spring Cache Abstraction documentation: https://docs.spring.io/spring-framework/reference/integration/cache.html
Ansible `community.general.proxmox_kvm` module documentation: https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_kvm_module.html
Proxmox VE API documentation: https://pve.proxmox.com/pve-docs/api-viewer/
