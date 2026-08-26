General Information

Date: 13.08.2026

Author: Volodymyr

Project: GreenCity (MVP)

Goal: Deploy three parts of the GreenCity project (backcore, backuser, frontend) on an Ubuntu VM running on Proxmox, using Docker and Docker Compose.

Objectives

Main goal: Set up the full GreenCity environment (2 backend services on Spring Boot + Angular frontend + PostgreSQL) in containers on one VM, without installing JDK/Node/Postgres manually on the host.

Other goals:

Make the deployment repeatable (build from zero on a clean VM using one set of commands).

Write a step-by-step md-instruction for the team.

Completed Tasks

Task Status Responsible Completion Date Notes

1 Prepare the VM (Ubuntu 22.04 on Proxmox, ufw, static IP) Done Volodymyr 13.08.2026 2 vCPU / 4 GB RAM / 25 GB SSD, vmbr0 bridge

2 Install Docker Engine + Docker Compose plugin Done Volodymyr 13.08.2026 Installed from the official repository download.docker.com

3 Write Dockerfiles for backcore, backuser, frontend Done Volodymyr 13.08.2026 Multi-stage build: maven:3.9-eclipse-temurin-21 → eclipse-temurin:21-jre; node:16 → nginx:1.25-alpine

4 Create docker-compose.yml (db, core, user, frontend) Done Volodymyr 13.08.2026 Service names core/user match application-docker.properties

5 Set up .env with credentials Done Volodymyr 13.08.2026 SMTP, Google OAuth, Azure Storage - placeholders CHANGE_ME until real values are given

6 Build images and first start (docker compose up -d) Done Volodymyr 13.08.2026 First build took about 5 minutes (downloading Maven dependencies and npm packages)

7 Check that services work (curl on ports 4200/8080/8060) Done Volodymyr 13.08.2026 All three services returned the expected status

Results

Actions completed:

Created a VM on Proxmox (Ubuntu Server 22.04 LTS), installed Docker Engine and Docker Compose plugin.

Wrote three Dockerfiles (backcore, backuser, frontend) using multi-stage builds, and one docker-compose.yml file that starts 4 containers: db (PostgreSQL 15), core (backcore, port 8080), user (backuser, port 8060), frontend (Nginx, port 4200).

Set up a healthcheck for PostgreSQL and used `depends_on: condition: service_healthy`, so the backend services do not try to connect to the database before it is ready.

Filled in the .env file with real values for DATASOURCE_URL/USER/PASSWORD. The fields for SMTP/Google OAuth/Azure Storage are still CHANGE_ME until they are agreed with the people responsible for these integrations.

Results achieved:

The whole GreenCity stack can start from zero with one command (`docker compose up -d`) in about 5-10 minutes on a clean VM.

`docker compose ps` shows all 4 containers as `running` / `healthy`.

The frontend at [http://192.168.0.110:4200/](http://192.168.0.110:4200/) loads successfully and connects to backcore/backuser inside the Docker network using the service names `core`/`user`.

Created a document called READMY.md with full step-by-step instructions so other team members can repeat the deployment.

Problems and Solutions

Problem Solution Status

1 The apps/backuser folder had no mvnw/mvnw.cmd files (unlike backcore), so the build stage failed with a plain JDK image Switched to the maven:3.9-eclipse-temurin-21 image for the build stage of both backend services, instead of using mvnw Done

2 npm ci in the frontend build had conflicts because of old peer dependencies in Angular 9 Used node:16-bullseye and, when needed, npm install --legacy-peer-deps Done

3 backuser started before PostgreSQL was ready to accept connections, and it kept crashing (CrashLoop) Added a healthcheck for the db service and depends_on: condition: service_healthy for core/user Done

4 There are no real SMTP/Google OAuth/Azure Storage credentials yet, so email sending, Google login, and file upload cannot be fully tested This functionality is temporarily unavailable; the values in .env stay as CHANGE_ME In progress (waiting for credentials)

Next Steps

Get the real SMTP, Google OAuth, and Azure Storage credentials, add them to .env, and test the related features again.

Consider adding a reverse proxy (Nginx) with one entry port and TLS (Let's Encrypt), if the service becomes available outside the internal network.

Set up CI that automatically builds Docker images when code is pushed to the main branch.

Add container monitoring.

Tools and Technologies Used

Docker / Docker Compose: used to containerize all 4 services (db, core, user, frontend), keep environments separate, and make the build repeatable.

Proxmox VE: virtualization - a separate Ubuntu VM for this deployment.

PostgreSQL 15: shared `greencity` database for both backend services (each with its own Liquibase changelog).

Spring Boot (Java 21, Maven): used for backcore and backuser, with a `docker` profile for configuration through environment variables.

Angular 9 + Nginx: used to build and serve the frontend static files.

ufw: basic firewall on the VM (only ports 22/4200/8080/8060 are open).

Comments and Conclusions

Deploying with Docker Compose made setting up the MVP much easier compared to using systemd services on separate VMs. Instead of 4 separate machines and installing JDK/Node/Postgres manually on each one, we now use one VM and one `docker compose up` command. The most important thing for the team to remember is that the service names in the compose file (`core`, `user`) are fixed inside `application-docker.properties`, and they cannot be changed without changing the code too. Before using this in production, it is recommended to store real secrets (SMTP/Google/Azure) using Docker secrets or a vault, instead of keeping them in a plain .env file on the VM's disk.

Attachments and Resources

Deployment guide: READMY.md (in the root of the repository).

Log of the first build: `docker compose logs -f` (saved locally on the VM).

Docker Compose documentation: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)

Docker Engine documentation (official repository for Ubuntu): [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

Github: [https://github.com/TroyanVova/GreenCity_Full.git](https://github.com/TroyanVova/GreenCity_Full.git)