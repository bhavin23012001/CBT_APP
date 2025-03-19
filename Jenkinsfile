pipeline {
    agent any
    
    environment {
        NEXUS_CREDENTIALS = credentials('NEXUS_CREDENTIALS')
        GITHUB_CREDENTIALS = credentials('GITHUB_CREDENTIALS')
        NEXUS_URL = "http://localhost:8081/repository/ci-artifacts"
        FLUTTER_BUILD = "flutter-app.apk"
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    try {
                        sh "git clone --depth=10 --filter=blob:none https://github.com/Bhavin2301/CBT_APP.git"
                    } catch (Exception e) {
                        echo "❌ Git Clone Failed! Check credentials & network."
                        error("Git Clone Failed")
                    }
                }
            }
        }

        stage('Code Quality Check') {
            steps {
                script {
                    try {
                        sh 'sonar-scanner -Dsonar.projectKey=FlutterApp -Dsonar.host.url=http://localhost:9000'
                    } catch (Exception e) {
                        echo "⚠️ SonarQube Analysis Failed!"
                    }
                }
            }
        }

        stage('Build Flutter App') {
            steps {
                script {
                    try {
                        sh 'flutter build apk --release'
                        sh "curl -u $NEXUS_CREDENTIALS --upload-file build/app/outputs/flutter-apk/app-release.apk $NEXUS_URL/$FLUTTER_BUILD"
                    } catch (Exception e) {
                        echo "❌ Flutter Build Failed!"
                        error("Flutter Build Failed")
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    try {
                        sh 'trivy filesystem . || echo "⚠️ Security scan failed!"'
                    } catch (Exception e) {
                        echo "⚠️ Trivy Security Scan Failed!"
                    }
                }
            }
        }

        stage('Monitoring') {
            steps {
                script {
                    try {
                        sh 'kubectl port-forward service/prometheus 9090:9090 || echo "⚠️ Monitoring Setup Failed!"'
                    } catch (Exception e) {
                        echo "⚠️ Prometheus Monitoring Setup Failed!"
                    }
                }
            }
        }
    }
}
