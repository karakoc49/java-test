pipeline {
    agent any

    stages {

        stage('Pull Repository') {
            steps {
                git url: 'https://github.com/karakoc49/java-test', branch: 'main'
            }
        }
            

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
                sh 'if [ ! "$(docker ps -q -f name=<name>)" ]; then
                        if [ "$(docker ps -aq -f status=exited -f name=<name>)" ]; then
                            # cleanup
                            docker rm <name>
                        fi
                        # run your container
                        docker run -d --name <name> my-docker-image
                    fi'
            }
        }
    }
}