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
                    git config --global --add safe.directory "*"
                    pip install -r requirements.txt
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
/*

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

        stage('Import Existing AWS Resources') {
        steps {
        dir('terraform') {
            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-ecr'
            ]]) {
                sh '''
                    set -ex

                    # Import existing Log Group
                    terraform import aws_cloudwatch_log_group.notes_logs /ecs/notes-app-v3 || true

                    # Import existing ALB
                    terraform import aws_lb.notes_alb arn:aws:elasticloadbalancing:us-east-1:921483785411:loadbalancer/app/notes-alb-v3/a59acd84b05eebab || true

                    # Import existing Target Group
                    terraform import aws_lb_target_group.notes_tg arn:aws:elasticloadbalancing:us-east-1:921483785411:targetgroup/notes-tg-v3/fa2f5027c1bcc846 || true
                '''
            }
        }
    }
}
*/

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
