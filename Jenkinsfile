pipeline {
    agent any

    environment {
        APP_NAME     = "vin-notes-app"
        AWS_REGION   = "us-east-1"
        ECR_URL      = "921483785411.dkr.ecr.us-east-1.amazonaws.com"
        BUILD_ID     = "${BUILD_NUMBER}"
        IMAGE_TAG    = "v${BUILD_ID}"
        FULL_IMAGE_NAME = "${ECR_URL}/${APP_NAME}:${IMAGE_TAG}"
        ECS_CLUSTER  = "notes-app-cluster"
        ECS_SERVICE  = "notes-service-v3"
        ECS_TASK_DEF = "vin-notes-task"
    }

    stages {
        stage('Install Python Dependencies') {
            steps {
                sh '''
                    pip install --upgrade pip --break-system-packages
                    pip install -r requirements.txt --break-system-packages

                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh 'PYTHONPATH=. python3 -m pytest -q'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --no-cache -t $FULL_IMAGE_NAME .'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
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
                            terraform apply -var="image_tag=$IMAGE_TAG" -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Register Task Definition + Update ECS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
                        aws ecs describe-task-definition \
                            --task-definition $ECS_TASK_DEF \
                            --region $AWS_REGION \
                            > current-task.json

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

                        aws ecs register-task-definition \
                            --cli-input-json file://updated-task.json \
                            --region $AWS_REGION

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
            echo '✅ CI/CD pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors.'
        }
    }
}
