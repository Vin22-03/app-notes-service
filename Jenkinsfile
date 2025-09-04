pipeline {
    agent any

    environment {
        APP_NAME        = "vin-notes-app"
        AWS_REGION      = "us-east-1"
        ECR_URL         = "921483785411.dkr.ecr.us-east-1.amazonaws.com"
        BUILD_ID        = "${BUILD_NUMBER}"
        IMAGE_TAG       = "v${BUILD_ID}"
        FULL_IMAGE_NAME = "${ECR_URL}/${APP_NAME}:${IMAGE_TAG}"
        ECS_CLUSTER     = "notes-app-cluster"
        ECS_SERVICE     = "notes-service-v4"
        ECS_TASK_DEF    = "vin-notes-task-v4"
    }

    stages {

        stage('Run Tests') {
            steps {
                sh '''
                    set -ex
                    pip install --break-system-packages --no-cache-dir -r requirements.txt
                    PYTHONPATH=. pytest -q
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -ex
                    docker build --no-cache -t $FULL_IMAGE_NAME .
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
                        set -ex
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_URL
                        docker push $FULL_IMAGE_NAME
                    '''
                }
            }
        }

        stage('Terraform Import Existing Resources') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            set -ex
                            terraform init

                            # Pass image_tag variable during import to avoid prompt failure
                            terraform import -var="image_tag=$IMAGE_TAG" aws_cloudwatch_log_group.notes_logs_v4 /ecs/notes-app-v4 || true
                            terraform import -var="image_tag=$IMAGE_TAG" aws_lb.notes_alb_v4 arn:aws:elasticloadbalancing:us-east-1:921483785411:loadbalancer/app/notes-alb-v4/85196f3ad9604335 || true
                            terraform import -var="image_tag=$IMAGE_TAG" aws_lb_target_group.notes_tg_v4 arn:aws:elasticloadbalancing:us-east-1:921483785411:targetgroup/notes-tg-v4/774f7dacb29d6f77 || true
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan After Import') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            set -ex
                            terraform plan -var="image_tag=$IMAGE_TAG"
                        '''
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            set -ex
                            terraform apply -var="image_tag=$IMAGE_TAG" -auto-approve
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline executed successfully with ECS deployment!'
        }
        failure {
            echo '❌ Pipeline failed. Please check logs above.'
        }
    }
}
