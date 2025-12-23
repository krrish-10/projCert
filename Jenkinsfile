pipeline {
    agent {
        label 'docker linux slave'
    }
    
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        IMAGE_NAME = 'php-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        CONTAINER_NAME = 'php-app-container'
        APP_PORT = '8080'
    }
    
    stages {
        stage('Verify Docker') {
            steps {
                script {
                    echo '====== Verifying Docker Installation ======'
                    sh 'docker --version'
                    sh 'docker ps'
                    echo '✓ Docker verified'
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/YOUR_USERNAME/projCert.git'
                echo '✓ Code checked out'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo '====== Building Docker Image ======'
                    sh '''
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    '''
                    echo '✓ Docker image built'
                    sh 'docker images | grep ${IMAGE_NAME}'
                }
            }
        }
        
        stage('Deploy Container') {
            steps {
                script {
                    echo '====== Deploying Container ======'
                    sh '''
                        # Stop old container
                        if [ $(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                            docker stop ${CONTAINER_NAME}
                            docker rm ${CONTAINER_NAME}
                        fi
                        
                        # Run new container
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${APP_PORT}:80 \
                            ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                    
                    // Health check
                    sh '''
                        sleep 3
                        for i in {1..10}; do
                            if curl -f http://localhost:${APP_PORT}/ > /dev/null 2>&1; then
                                echo "✓ Application is responding"
                                break
                            else
                                echo "Attempt $i: Waiting..."
                                sleep 2
                            fi
                        done
                    '''
                    echo '✓ Container deployed'
                }
            }
        }
    }
    
    post {
        failure {
            script {
                echo '====== Cleanup on Failure ======'
                sh '''
                    if [ $(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                        docker stop ${CONTAINER_NAME}
                        docker rm ${CONTAINER_NAME}
                    fi
                    docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true
                '''
            }
        }
        
        always {
            cleanWs()
        }
    }
}
