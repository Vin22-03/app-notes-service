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
        TF_BUCKET       = "vin-tfstate-bucket"
        TF_STATE_KEY    = "notes-app/terraform.tfstate"
        DEPLOYMENT_GROUP = "notes-app-deployment-group"
        CODEDEPLOY_APP   = "notes-app-codedeploy"
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

        stage('Terraform Deploy with S3 Backend') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-ecr'
                    ]]) {
                        sh '''
                            set -ex
                            terraform init -force-copy \
                                           -backend-config="bucket=$TF_BUCKET" \
                                           -backend-config="key=$TF_STATE_KEY" \
                                           -backend-config="region=$AWS_REGION"

                            terraform apply -var="image_tag=$IMAGE_TAG" -var="ecs_cluster=$ECS_CLUSTER" -auto-approve
                        '''
                    }
                }
            }
        }

       stage('Trigger CodeDeploy Deployment') {
           steps {
               withCredentials([[
                     $class: 'AmazonWebServicesCredentialsBinding',
                       credentialsId: 'aws-ecr'
                  ]]) {
             sh '''
                set -ex
                    aws deploy create-deployment \
                        --application-name vin-notes-codedeploy \
                        --deployment-group-name vin-notes-dg \
                        --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
                        --region us-east-1 \
                        --revision revisionType=AppSpecContent,appSpecContent={content="version: 1\nResources:\n  - TargetService:\n      Type: AWS::ECS::Service\n      Properties:\n        TaskDefinition: vin-notes-task-v4\n        LoadBalancerInfo:\n          ContainerName: notes-app-v4\n          ContainerPort: 8000"}

            '''
        }
    }
}

        stage('Verify ECS Service') {
            steps {
                sh '''
                    aws ecs describe-services \
                      --cluster $ECS_CLUSTER \
                      --services $ECS_SERVICE \
                      --region $AWS_REGION
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline with Blue/Green Deployment completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors!'
        }
    }
}
