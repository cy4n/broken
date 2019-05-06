pipeline {
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
    }
    agent any
    environment {
        CURRENT_IP = 'docker.for.mac.localhost'
    }
    stages {
        stage('Show runtime version') {
            steps {
                sh 'java -version'
                sh './mvnw --version'
                sh 'printenv| sort'
            }
        }
        stage('mvn cleanup') {
            steps {
                sh './mvnw clean'
            }
        }
        stage('Unit Tests') {
            steps {
                sh './mvnw test'
            }
        }
        stage('dependency check') {
            steps {
                sh './mvnw dependency-check:check'
            }
        }
        stage('package') {
            steps {
                sh './mvnw -DskipTests package'
            }
        }
        stage('artifact upload') {
            steps {
                echo 'dont upload that shit'
            }
        }
        stage('docker build') {
            steps {
                sh "docker build . -t cy4n/broken:${env.GIT_COMMIT}"
            }
        }
        stage('docker push') {
            steps {
                echo 'dont upload that shit'
            }
        }
        stage('container security scan') {
            steps {
                script {
                    try {
                        echo "needs jenkins port 9279 exposed :-(, which is not happening in the demo dockerized jenkins, sorry"
                        echo "claire-scanner -c http://${CURRENT_IP}:6060 --ip ${CURRENT_IP} -r clair-report.json -l clair.log -w clair-whitelist.yml cy4n/broken:${env.GIT_COMMIT}"
                        sh 'exit 1'
                    }
                    catch (exc) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('api security scan') {
            steps {
                sh "docker run -d -p10000:8080 --name 'sut' cy4n/broken:${env.GIT_COMMIT}"
                sleep 20
                script {
                    try {
                        sh "docker run -t owasp/zap2docker-weekly zap-baseline.py -t http://${CURRENT_IP}:10000"
                    }
                    catch (exc) {
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('docker cleanup') {
            steps {
                sh 'docker stop sut'
                sh 'docker container rm sut'
            }
        }
    }
}
