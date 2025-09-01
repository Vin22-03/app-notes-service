pipeline {
    agent {
        docker {
            image 'python:3.10-slim'
        }
    }

    environment {
        PYTHONPATH = '.'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pytest -q'
            }
        }
    }
}

pipeline {
    agent {
        docker {
            image 'docker:24.0.2-dind'  // Newer Docker-in-Docker image
            args '--privileged'         // Required for Docker daemon
        }
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'vin-notes-app'
        ECR_URI = '921483785411.dkr.ecr.us-east-1.amazonaws.com/vin-notes-app'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO .'
                sh 'docker tag $ECR_REPO:latest $ECR_URI:latest'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_URI
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push $ECR_URI:latest'
            }
        }
    }
}

