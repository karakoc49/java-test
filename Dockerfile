FROM openjdk:11

COPY . /app

WORKDIR /app

RUN javac Hello.java

CMD ["java","Hello"]