pipeline {
    agent any

    stages {
        stage('Build') { 
            steps {
                //Java derleme işlemi
                sh 'javac Hello.java'
            }
        }

        stage('Run') {
            steps {
                //Derlenen kodu çalıştırma işlemi
                sh 'java Hello'
            }
        }

        stage('Building and Pushing Docker Image') {
            steps {
                //Docker imajının buildini alıyorum
                sh 'docker build --tag java_test .'
                //Docker imajını taglıyorum
                sh 'docker tag java_test karakoc49/java_test'
                //Docker imajını repoya(https://hub.docker.com/repository/docker/karakoc49/java_test) yüklüyorum
                sh 'docker push karakoc49/java_test'
            }
        }

        stage('Running Docker Container') {
            steps {
                //Eğer ikinci sunucuda halihazırda Java_TEST konteynerı varsa durdurup siliyor, eğer yoksa yarattığım imajı repomdan çekip konteyner olarak detached bir şekilde Java_TEST adı altında koşturuyor
                sh 
                '''
                app="Java_TEST"
                if docker ps | awk -v app="$app" 'NR > 1 && $NF == app{ret=1; exit} END{exit !ret}'; then
                    docker stop "$app" && docker rm -f "$app"
                fi
                '''
                sh 'docker run -d --name Java_TEST karakoc49/java_test'
            }
        }
    }
}