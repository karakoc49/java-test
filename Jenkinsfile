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
                sh 'docker rm Java_TEST'
                sh 'docker run -d --name Java_TEST karakoc49/java_test'
            }
        }
    }
}