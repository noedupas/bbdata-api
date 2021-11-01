FROM openjdk:8-jdk-alpine

# User privileges
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR
ARG JAR_FILE=./bbdata-api-2.0.0-alpha.jar
COPY ${JAR_FILE} app.jar

# Copy config
COPY ./bbdata_config.yml config/application.properties

# Expose port on host
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app.jar"]