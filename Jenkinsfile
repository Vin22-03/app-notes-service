pipeline {
    agent any

    environment {
        PYTHONPATH = '.'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/Vin22-03/app-notes-service.git', branch: 'main'
            }
        }

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
