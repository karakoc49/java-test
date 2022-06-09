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
                sh '''
                        if [ ! "$(docker ps -q -f name=Java_TEST)" ]; then
                            if [ "$(docker ps -aq -f status=exited -f name=Java_TEST)" ]; then
                                # stop
                                docker stop Java_TEST
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