pipeline {
    agent any

    stages {

        stage('Pull Repository') {
            steps{
                git clone 'https://github.com/karakoc49/java-test'
            }
        }
            

        stage('Build') { 
            steps {
                sh 'javac Hello.java' 
            }
        }
    }
}