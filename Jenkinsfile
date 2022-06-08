pipeline {
    agent any

    stages {
        stage('Build') { 
            steps {
                sh 'javac Hello.java'
            }
        }

        stage('Run') {
            steps {
                sh 'java Hello'
            }
        }

        stage('Building and Pushing Docker Image') {
            steps {
                sh 'docker build --tag java_test .'
                sh 'docker tag java_test karakoc49/java_test'
                sh 'docker push karakoc49/java_test'
            }
        }

        stage('Running Docker Container') {
            steps {
                sh '''
                        if [ ! "$(docker ps -q -f name=Java_TEST)" ]; then
                            if [ "$(docker ps -aq -f status=exited -f name=Java_TEST)" ]; then
                                # cleanup
                                docker rm Java_TEST
                            fi
                            # run your container
                            docker run -d --name Java_TEST karakoc49/java_test
                        fi
                    '''
            }
        }
    }
}