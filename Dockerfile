FROM adoptopenjdk/openjdk11:alpine-jre
EXPOSE 8080

RUN mkdir /app
COPY target/broken*.jar /app/broken.jar
WORKDIR /app
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/broken.jar"]
