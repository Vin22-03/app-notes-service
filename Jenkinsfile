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
