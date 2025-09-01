pipeline {
    agent {
        docker {
            image 'docker:24.0.2-dind'
            args '--privileged' // run as root to allow pip installs
        }
    }

    environment {
        APP_NAME = "notes-app"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                apk add --no-cache python3 py3-pip
                python3 -m ensurepip
                sh 'pip3 install --upgrade pip'
                sh 'pip3 install -r requirements.txt'
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
