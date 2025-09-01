pipeline {
    agent {
        docker {
            image 'python:3.10-slim'
            args '-u root:root' // run as root to allow pip installs
        }
    }

    environment {
        APP_NAME = "notes-app"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pytest -q'
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
                    credentialsId: 'aws-ecr'  // <-- Replace this with your real AWS credential ID in Jenkins
                ]]) {
                    sh '''
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
                        docker tag $APP_NAME <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/$APP_NAME
                        docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/$APP_NAME
                    '''
                }
            }
        }
    }
}
