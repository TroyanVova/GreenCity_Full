pipeline {
    agent { label 'greencity-build' }

    environment {
        STAGING_VMID = '110'
        STAGING_IP   = '192.168.0.110'
        STAGING_NAME = 'greencity-staging'

        ANSIBLE_DIR = '/opt/greencity-ondemand-ansible'
        PVE_NODE    = 'pve'
        GATEWAY     = '192.168.0.1'
        NETMASK     = '24'

        REGISTRY      = '192.168.0.123:5000'
        MONITORING_IP = '192.168.0.122'

        DEPLOY_KEY  = '/home/jenkins-agent/.ssh/deploy_key'
        DEPLOY_USER = 'deployer'
        REMOTE_DIR  = '/home/deployer/greencity'
        SSH_OPTS    = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
    }

    stages {
	
		stage('Code Quality (SonarCloud)') {
			steps {
				withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
					dir('apps/backcore') {
						sh 'mvn -B test org.sonarsource.scanner.maven:sonar-maven-plugin:sonar ' +
						   '-Dsonar.organization=troyanvova -Dsonar.projectKey=greencity-backcore ' +
						   '-Dsonar.host.url=https://sonarcloud.io -Dsonar.login=$SONAR_TOKEN'
					}
					dir('apps/backuser') {
						sh 'mvn -B test org.sonarsource.scanner.maven:sonar-maven-plugin:sonar ' +
						   '-Dsonar.organization=troyanvova -Dsonar.projectKey=greencity-backcore ' +
						   '-Dsonar.host.url=https://sonarcloud.io -Dsonar.login=$SONAR_TOKEN'
					}
				}
			}
		}

        stage('Ensure staging VM exists & running') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'proxmox-api-token',
                                                   usernameVariable: 'PVE_TOKEN_ID',
                                                   passwordVariable: 'PVE_TOKEN_SECRET')]) {
                    sh """
                        cd ${ANSIBLE_DIR}
                        ansible-playbook provision.yml \
                          -e pve_api_token_id="${'$'}PVE_TOKEN_ID" \
                          -e pve_api_token_secret="${'$'}PVE_TOKEN_SECRET" \
                          -e pve_node=${PVE_NODE} \
                          -e vmid=${STAGING_VMID} \
                          -e vm_name=${STAGING_NAME} \
                          -e vm_ip=${STAGING_IP} \
                          -e vm_gateway=${GATEWAY} \
                          -e vm_netmask=${NETMASK}
                    """
                }
            }
        }

        stage('Wait for SSH') {
            steps {
                sh "cd ${ANSIBLE_DIR} && ansible-playbook wait_ssh.yml -e vm_ip=${STAGING_IP}"
            }
        }

        stage('Generate frontend environment.prod.ts') {
            steps {
                withCredentials([
                    string(credentialsId: 'gc-google-client-id',        variable: 'GOOGLE_CLIENT_ID'),
                    string(credentialsId: 'gc-api-keys',                variable: 'API_KEYS'),
                    string(credentialsId: 'gc-api-map-key',             variable: 'API_MAP_KEY'),
                    string(credentialsId: 'gc-agm-core-module-api-key', variable: 'AGM_CORE_MODULE_API_KEY'),
                    string(credentialsId: 'gc-firebase-api-key',             variable: 'FIREBASE_API_KEY'),
                    string(credentialsId: 'gc-firebase-auth-domain',         variable: 'FIREBASE_AUTH_DOMAIN'),
                    string(credentialsId: 'gc-firebase-database-url',        variable: 'FIREBASE_DATABASE_URL'),
                    string(credentialsId: 'gc-firebase-project-id',         variable: 'FIREBASE_PROJECT_ID'),
                    string(credentialsId: 'gc-firebase-storage-bucket',      variable: 'FIREBASE_STORAGE_BUCKET'),
                    string(credentialsId: 'gc-firebase-messaging-sender-id', variable: 'FIREBASE_MESSAGING_SENDER_ID'),
                    string(credentialsId: 'gc-firebase-app-id',              variable: 'FIREBASE_APP_ID'),
                    string(credentialsId: 'gc-firebase-measurement-id',      variable: 'FIREBASE_MEASUREMENT_ID')
                ]) {
                    sh """
                        BACKEND_LINK='http://${STAGING_IP}:8080/' \
                        BACKEND_USER_LINK='http://${STAGING_IP}:8060/' \
                        SOCKET='http://${STAGING_IP}:8080/socket' \
                        FRONTEND_LINK='http://${STAGING_IP}/' \
                        BACKEND_CHAT_LINK='http://${STAGING_IP}:8061/' \
                        CHAT_SOCKET='http://${STAGING_IP}:8061/socket' \
                        BACKEND_UBS_LINK='http://${STAGING_IP}:8070/' \
                        BACKEND_UBS_ADMIN_LINK='http://${STAGING_IP}:8070/ubs' \
                        API_KEYS="${'$'}API_KEYS" \
                        API_MAP_KEY="${'$'}API_MAP_KEY" \
                        AGM_CORE_MODULE_API_KEY="${'$'}AGM_CORE_MODULE_API_KEY" \
                        GOOGLE_CLIENT_ID="${'$'}GOOGLE_CLIENT_ID" \
                        FIREBASE_API_KEY="${'$'}FIREBASE_API_KEY" \
                        FIREBASE_AUTH_DOMAIN="${'$'}FIREBASE_AUTH_DOMAIN" \
                        FIREBASE_DATABASE_URL="${'$'}FIREBASE_DATABASE_URL" \
                        FIREBASE_PROJECT_ID="${'$'}FIREBASE_PROJECT_ID" \
                        FIREBASE_STORAGE_BUCKET="${'$'}FIREBASE_STORAGE_BUCKET" \
                        FIREBASE_MESSAGING_SENDER_ID="${'$'}FIREBASE_MESSAGING_SENDER_ID" \
                        FIREBASE_APP_ID="${'$'}FIREBASE_APP_ID" \
                        FIREBASE_MEASUREMENT_ID="${'$'}FIREBASE_MEASUREMENT_ID" \
                        envsubst < apps/frontend/src/environments/environment.prod.ts > environment.prod.ts.generated
                        mv environment.prod.ts.generated apps/frontend/src/environments/environment.prod.ts
                    """
                }
            }
        }

        stage('Build & push images') {
            steps {
                script {
                    env.IMAGE_TAG = env.GIT_COMMIT.take(7)
                }
                sh """
                    docker build -t ${REGISTRY}/greencity-core:${env.IMAGE_TAG}     -t ${REGISTRY}/greencity-core:latest     apps/backcore
                    docker build -t ${REGISTRY}/greencity-user:${env.IMAGE_TAG}     -t ${REGISTRY}/greencity-user:latest     apps/backuser
                    docker build -t ${REGISTRY}/greencity-frontend:${env.IMAGE_TAG} -t ${REGISTRY}/greencity-frontend:latest apps/frontend

                    docker push ${REGISTRY}/greencity-core:${env.IMAGE_TAG}
                    docker push ${REGISTRY}/greencity-core:latest
                    docker push ${REGISTRY}/greencity-user:${env.IMAGE_TAG}
                    docker push ${REGISTRY}/greencity-user:latest
                    docker push ${REGISTRY}/greencity-frontend:${env.IMAGE_TAG}
                    docker push ${REGISTRY}/greencity-frontend:latest
                """
            }
        }

        stage('Provision secrets (.env)') {
            steps {
                withCredentials([
                    string(credentialsId: 'gc-postgres-password', variable: 'POSTGRES_PASSWORD'),
                    string(credentialsId: 'gc-redis-password',    variable: 'REDIS_PASSWORD'),
                    string(credentialsId: 'gc-email-password',    variable: 'EMAIL_PASSWORD'),
                    string(credentialsId: 'gc-google-client-id',  variable: 'GOOGLE_CLIENT_ID')
                ]) {
                    sh """
                        cat > env_file.tmp <<EOF
POSTGRES_DB=greencity
POSTGRES_USER=greencity
POSTGRES_PASSWORD=${'$'}{POSTGRES_PASSWORD}
DATASOURCE_URL=jdbc:postgresql://db:5432/greencity
DATASOURCE_USER=greencity
DATASOURCE_PASSWORD=${'$'}{POSTGRES_PASSWORD}
REDIS_PASSWORD=${'$'}{REDIS_PASSWORD}
EMAIL_ADDRESS=your.smtp.account@gmail.com
EMAIL_PASSWORD=${'$'}{EMAIL_PASSWORD}
GOOGLE_CLIENT_ID=${'$'}{GOOGLE_CLIENT_ID}
CORS_ALLOWED_ORIGINS=http://${STAGING_IP},http://${STAGING_IP}:4200,http://${STAGING_IP}:4205
REGISTRY=${REGISTRY}
IMAGE_TAG=${env.IMAGE_TAG}
EOF
                        ssh -i ${DEPLOY_KEY} ${SSH_OPTS} ${DEPLOY_USER}@${STAGING_IP} 'mkdir -p ${REMOTE_DIR}'
                        scp -i ${DEPLOY_KEY} ${SSH_OPTS} env_file.tmp ${DEPLOY_USER}@${STAGING_IP}:${REMOTE_DIR}/.env
                        ssh -i ${DEPLOY_KEY} ${SSH_OPTS} ${DEPLOY_USER}@${STAGING_IP} 'chmod 600 ${REMOTE_DIR}/.env'
                        rm -f env_file.tmp
                    """
                }
            }
        }


        stage('Sync compose files to staging VM') {
            steps {
                sh """
                    ssh -i ${DEPLOY_KEY} ${SSH_OPTS} ${DEPLOY_USER}@${STAGING_IP} 'mkdir -p ${REMOTE_DIR}/lb'
                    scp -i ${DEPLOY_KEY} ${SSH_OPTS} docker-compose.yml promtail-config.yml ${DEPLOY_USER}@${STAGING_IP}:${REMOTE_DIR}/
                    scp -i ${DEPLOY_KEY} ${SSH_OPTS} lb/nginx.conf ${DEPLOY_USER}@${STAGING_IP}:${REMOTE_DIR}/lb/
                """
            }
        }

        stage('Pull & start stack') {
            steps {
                sh """
                    ssh -i ${DEPLOY_KEY} ${SSH_OPTS} ${DEPLOY_USER}@${STAGING_IP} '
                        cd ${REMOTE_DIR} &&
                        docker compose --env-file .env pull &&
                        docker compose --env-file .env up -d
                    '
                """
            }
        }

        stage('Register in monitoring') {
            steps {
                sh """
                    cat > staging-app.json <<EOF
[{"targets": ["${STAGING_IP}:8080", "${STAGING_IP}:8060"], "labels": {"env": "staging"}}]
EOF
                    cat > staging-node.json <<EOF
[{"targets": ["${STAGING_IP}:9100"], "labels": {"env": "staging"}}]
EOF
                    cat > staging-cadvisor.json <<EOF
[{"targets": ["${STAGING_IP}:8082"], "labels": {"env": "staging"}}]
EOF
                    scp -i ${DEPLOY_KEY} ${SSH_OPTS} staging-app.json staging-node.json staging-cadvisor.json \
                        monitoring@${MONITORING_IP}:/opt/monitoring/file_sd/
                    rm -f staging-app.json staging-node.json staging-cadvisor.json
                """
            }
        }

        stage('Health check') {
            steps {
                sh """
                    sleep 20
                    curl -fsS http://${STAGING_IP}:8080/actuator/health
                    curl -fsS http://${STAGING_IP}:8060/actuator/health
                    curl -fsS -o /dev/null http://${STAGING_IP}:4200/
                """
            }
        }
    }

    post {
        success { echo "Staging update: http://${STAGING_IP}/ (commit ${env.GIT_COMMIT})" }
		failure {
			withCredentials([string(credentialsId: 'discord-cicd-webhook', variable: 'DISCORD_WEBHOOK_URL')]) {
			  sh '''
				curl -H "Content-Type: application/json" -X POST \
				  -d "{\\"content\\": \\"${JOB_NAME} #${BUILD_NUMBER} failed: ${BUILD_URL}\\"}" \
				  "$DISCORD_WEBHOOK_URL"
			  '''
			}
		}
    }
}