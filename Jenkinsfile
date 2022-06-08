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
                sh 'docker build --tag java-test .'
                sh 'docker image tag java-test karakog49/java-test'
                sh 'docker push karakoc49/java-test'
            }
        }

        stage('Running Docker Container') {
            steps {
                //sh 'docker rm Java-TEST'
                sh 'docker run -d --name Java-TEST karakoc49/java-test'
            }
        }
    }
}