pipeline {
    agent any

environment {
    NEXUS_CREDENTIALS = credentials('NEXUS_CREDENTIALS')
    GITHUB_CREDENTIALS = credentials('GITHUB_CREDENTIALS')
}
    
    environment {
        NEXUS_URL = "http://localhost:8081/repository/ci-artifacts"
        NEXUS_CREDENTIALS = credentials('NEXUS_CREDENTIALS') // Stored in Jenkins
        FLUTTER_BUILD = "flutter-app.apk"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Bhavin2301/CBT_APP.git'  // Change to your actual repo
            }
        }

        stage('Code Quality Check') {
            steps {
                sh 'sonar-scanner -Dsonar.projectKey=FlutterApp -Dsonar.host.url=http://localhost:9000'
            }
        }

        stage('Build Flutter App') {
            steps {
                sh 'flutter build apk --release'
                sh 'curl -u $NEXUS_CREDENTIALS --upload-file build/app/outputs/flutter-apk/app-release.apk $NEXUS_URL/$FLUTTER_BUILD'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'trivy filesystem .'
            }
        }

        stage('Monitoring') {
            steps {
                sh 'kubectl port-forward service/prometheus 9090:9090'
            }
        }
    }
}
