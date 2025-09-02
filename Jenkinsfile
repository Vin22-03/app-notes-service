pipeline {
    agent {
        docker {
            image 'python:3.10-slim'
            args '--user root'
        }
    }

    environment {
        APP_NAME = "vin-notes-app"
        AWS_REGION = "us-east-1"
        ECR_URL = "921483785411.dkr.ecr.us-east-1.amazonaws.com"
        FULL_IMAGE_NAME = "${ECR_URL}/${APP_NAME}:${IMAGE_TAG}"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        ECS_CLUSTER = "notes-app-cluster"       // 🔁 Replace with your actual ECS cluster name
        ECS_SERVICE = "notes-service-v3"       // 🔁 Replace with your actual ECS service name
        ECS_TASK_DEF = "vin-notes-task"         // 🔁 Replace with your ECS task definition name
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                    apt-get update && apt-get install -y awscli docker.io unzip wget jq
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
                sh '''
                    if ! command -v terraform >/dev/null; then
                        wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
                        unzip -o /tmp/terraform.zip -d /usr/local/bin/
                        chmod +x /usr/local/bin/terraform
                    fi
                    terraform -version
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh 'PYTHONPATH=. pytest -q'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build --no-cache --build-arg CACHEBUST=$(date +%s) -t $FULL_IMAGE_NAME .
         
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
                        aws --version
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_URL

                        docker push $FULL_IMAGE_NAME
                    '''
                }
            }
        }

        stage('Terraform Apply (Infra)') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Register New Task Definition + Update ECS Service') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
                        echo "📦 Fetching current ECS Task Definition..."
                        aws ecs describe-task-definition \
                            --task-definition $ECS_TASK_DEF \
                            --region $AWS_REGION \
                            > current-task.json

                        echo "🧪 Updating image to $FULL_IMAGE_NAME..."

                        NEW_TASK_DEF=$(cat current-task.json | jq --arg IMAGE "$FULL_IMAGE_NAME" '
                            {
                                family: .taskDefinition.family,
                                executionRoleArn: .taskDefinition.executionRoleArn,
                                networkMode: .taskDefinition.networkMode,
                                requiresCompatibilities: .taskDefinition.requiresCompatibilities,
                                cpu: .taskDefinition.cpu,
                                memory: .taskDefinition.memory,
                                containerDefinitions: (
                                    .taskDefinition.containerDefinitions | map(
                                        .image = $IMAGE
                                    )
                                )
                            }')

                        echo "$NEW_TASK_DEF" > updated-task.json

                        echo "📌 Registering new revision..."
                        aws ecs register-task-definition \
                            --cli-input-json file://updated-task.json \
                            --region $AWS_REGION

                        echo "🚀 Triggering ECS Deployment..."
                        aws ecs update-service \
                            --cluster $ECS_CLUSTER \
                            --service $ECS_SERVICE \
                            --force-new-deployment \
                            --region $AWS_REGION
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline executed successfully with new ECS deployment!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors.'
        }
    }
}
