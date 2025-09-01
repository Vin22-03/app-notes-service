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
        FULL_IMAGE_NAME = "${ECR_URL}/${APP_NAME}"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                    apt-get update && apt-get install -y awscli docker.io unzip wget
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''

                // Install Terraform only if not present
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

        stage('Check Docker') {
            steps {
                sh 'docker --version'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $APP_NAME .'
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

                        docker tag $APP_NAME $FULL_IMAGE_NAME
                        docker push $FULL_IMAGE_NAME
                    '''
                }
            }
        }

       

        stage('Terraform Apply (Deploy New Infra)') {
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
    }

    post {
        success {
            echo '✅ CI/CD pipeline with Terraform destroy & deploy completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs and fix errors.'
        }
    }
}
