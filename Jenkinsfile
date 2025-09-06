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

        // 🔒 New DevSecOps Stage 1 — Trivy Image Scan
        stage('Trivy Scan 🔍') {
            steps {
                sh '''
                    set -ex
                    echo "🔍 Running Trivy vulnerability scan..."
                    docker build -t $APP_NAME:ci-$BUILD_ID .
                    trivy image --exit-code 0 --severity CRITICAL,HIGH $APP_NAME:ci-$BUILD_ID
                '''
            }
        }

        // 📦 New DevSecOps Stage 2 — SBOM Generation with Syft
        stage('Generate SBOM 📦') {
            steps {
                sh '''
                    set -ex
                    echo "📦 Generating SBOM..."
                    syft $APP_NAME:ci-$BUILD_ID -o spdx-json > sbom-$BUILD_ID.json
                '''
            }
        }
            
    stage('SonarQube Analysis') {
       steps {
        withSonarQubeEnv('SonarLocal') {
            withEnv([
    "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64",
    "PATH=/usr/lib/jvm/java-17-openjdk-amd64/bin:${env.PATH}"
  ]) {
            sh 'sonar-scanner -Dsonar.projectKey=vin-notes-app -Dsonar.sources=src -Dsonar.host.url=http://host.docker.internal:9000'
          }
      }
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
                            --revision revisionType=AppSpecContent,appSpecContent={content="version: 1\\nResources:\\n  - TargetService:\\n      Type: AWS::ECS::Service\\n      Properties:\\n        TaskDefinition: vin-notes-task-v4\\n        LoadBalancerInfo:\\n          ContainerName: notes-app-v4\\n          ContainerPort: 8000"}
                    '''
                }
            }
        }

        stage('Verify ECS Service') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
                        set -ex
                        aws ecs describe-services \
                            --cluster $ECS_CLUSTER \
                            --services $ECS_SERVICE \
                            --region $AWS_REGION
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD pipeline with DevSecOps + Blue/Green ECS Deployment completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors!'
        }
    }
}
