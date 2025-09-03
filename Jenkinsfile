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
        ECS_SERVICE     = "notes-service-v3"
        ECS_TASK_DEF    = "vin-notes-task"
    }

    stages {
        stage('Run Tests') {
            steps {
                sh '''
                    set -ex
                    git config --global --add safe.directory "*"
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

        // ⚠️ TEMPORARY STAGE – Use only once to destroy old infra
        stage('Destroy Old Infra (One Time)') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            set -ex
                            terraform init
                            terraform destroy -var="image_tag=dummy" -auto-approve
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
                            terraform init
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
