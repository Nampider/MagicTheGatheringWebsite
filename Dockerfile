FROM eclipse-temurin:17

LABEL maintainer="devchrisnam@gmail.com"

WORKDIR /app

COPY target/magicWebsite-0.0.1-SNAPSHOT.jar /app/magic-backend-docker.jar

ENTRYPOINT ["java", "-jar", "magic-backend-docker.jar"]