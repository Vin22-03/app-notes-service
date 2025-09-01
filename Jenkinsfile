pipeline {
    agent {
        docker {
            image 'docker:24.0.2-dind'
            args '--privileged' // Needed for Docker-in-Docker
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
                    pip3 install --upgrade pip
                    pip3 install -r requirements.txt
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
                    credentialsId: 'aws-ecr' // ✅ Replace with your actual credential ID
                ]]) {
                    sh '''
                        aws ecr get-login-password --region us-east-1 | \
                        docker login --username AWS --password-stdin 921483785411.dkr.ecr.us-east-1.amazonaws.com

                        docker tag $APP_NAME 921483785411.dkr.ecr.us-east-1.amazonaws.com/$APP_NAME
                        docker push 921483785411.dkr.ecr.us-east-1.amazonaws.com/$APP_NAME
                    '''
                }
            }
        }

    }
}
