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
    }
}