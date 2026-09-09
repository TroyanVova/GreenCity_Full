pipeline {
    agent { label 'greencity-build' }

    parameters {
        string(name: 'SERVER_IP', defaultValue: '',
               description: 'k3s server Elastic IP — `terraform output -raw k3s_server_public_ip` in infra/')
        string(name: 'ALB_DNS', defaultValue: '',
               description: 'ALB DNS name for the health-check stage — `terraform output -raw alb_dns_name` in infra/')
        string(name: 'DB_ENDPOINT', defaultValue: '',
               description: 'RDS endpoint (host:port) — `terraform output -raw db_endpoint` in infra/. Leave blank to skip re-writing the Secret.')
    }

    environment {
        AWS_REGION      = 'us-east-1'
        PROJECT         = 'greencity'
        SSH_OPTS        = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
        SSH_KEY         = '/home/jenkins-agent/.ssh/greencity-k3s'
        AWS_PROFILE     = 'greencity-cloud'
        KUBECONFIG      = '/home/jenkins-agent/.kube/greencity-cloud'
        NAMESPACE       = 'greencity'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Resolve params') {
            steps {
                script {
                    if (!params.SERVER_IP?.trim()) {
                        error("SERVER_IP is required — run 'terraform output -raw k3s_server_public_ip' in infra/ and pass it as a build parameter.")
                    }
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.ECR_ACCOUNT_ID = sh(
                        script: "aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text",
                        returnStdout: true
                    ).trim()
                    env.REGISTRY = "${env.ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                }
            }
        }

        stage('Build & push images') {
            steps {
                sh """
                    set -eux
                    aws --profile ${AWS_PROFILE} ecr get-login-password --region ${AWS_REGION} \
                        | docker login --username AWS --password-stdin ${REGISTRY}

                    for svc in frontend backcore backuser; do
                        docker build -t ${REGISTRY}/${PROJECT}-\${svc}:${IMAGE_TAG} apps/\${svc}
                        docker push ${REGISTRY}/${PROJECT}-\${svc}:${IMAGE_TAG}
                    done
                """
            }
        }

        stage('Open SSH tunnel to k3s') {
            steps {
                sh """
                    set -eux
                    pkill -f "6443:127.0.0.1:6443" || true
                    ssh -i ${SSH_KEY} ${SSH_OPTS} -f -N -L 6443:127.0.0.1:6443 ec2-user@${params.SERVER_IP}
                    sleep 3
                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} get pods
                """
            }
        }

        stage('Update Secret') {
            when {
                expression { params.DB_ENDPOINT?.trim() }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'gc-cloud-db-password', variable: 'DB_PASSWORD'),
                    string(credentialsId: 'gc-cloud-redis-password', variable: 'REDIS_PASSWORD'),
                    string(credentialsId: 'gc-cloud-email-address', variable: 'EMAIL_ADDRESS'),
                    string(credentialsId: 'gc-cloud-email-password', variable: 'EMAIL_PASSWORD')
                ]) {
                    sh """
                        set -eux
                        kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} create secret generic greencity-secrets \
                            --from-literal=SPRING_DATASOURCE_URL="jdbc:postgresql://${params.DB_ENDPOINT}/${PROJECT}" \
                            --from-literal=SPRING_DATASOURCE_USERNAME="greencity_admin" \
                            --from-literal=SPRING_DATASOURCE_PASSWORD="\$DB_PASSWORD" \
                            --from-literal=REDIS_PASSWORD="\$REDIS_PASSWORD" \
                            --from-literal=CORS_ALLOWED_ORIGINS="http://${params.ALB_DNS}" \
                            --dry-run=client -o yaml | kubectl --kubeconfig=${KUBECONFIG} apply -f -
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    set -eux
                    kubectl --kubeconfig=${KUBECONFIG} apply -f k8s/redis.yaml
                    kubectl --kubeconfig=${KUBECONFIG} apply -f k8s/backcore.yaml
                    kubectl --kubeconfig=${KUBECONFIG} apply -f k8s/backuser.yaml
                    kubectl --kubeconfig=${KUBECONFIG} apply -f k8s/frontend.yaml

                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} set image deployment/frontend frontend=${REGISTRY}/${PROJECT}-frontend:${IMAGE_TAG}
                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} set image deployment/backcore backcore=${REGISTRY}/${PROJECT}-backcore:${IMAGE_TAG}
                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} set image deployment/backuser backuser=${REGISTRY}/${PROJECT}-backuser:${IMAGE_TAG}

                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} rollout status deployment/frontend --timeout=180s
                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} rollout status deployment/backcore --timeout=180s
                    kubectl --kubeconfig=${KUBECONFIG} -n ${NAMESPACE} rollout status deployment/backuser --timeout=180s
                """
            }
        }

        stage('Health check') {
            when {
                expression { params.ALB_DNS?.trim() }
            }
            steps {
                sh """
                    set -eux
                    curl -fsS http://${params.ALB_DNS}/ > /dev/null
                    curl -fsS http://${params.ALB_DNS}/core/actuator/health | grep -q '"status":"UP"'
                    curl -fsS http://${params.ALB_DNS}/user/actuator/health | grep -q '"status":"UP"'
                """
            }
        }
    }

    post {
        always {
            sh 'pkill -f "6443:127.0.0.1:6443" || true'
        }
    }
}
