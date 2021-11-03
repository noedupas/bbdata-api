FROM openjdk:8-jdk-alpine

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

# User privileges
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR
COPY ./bbdata-api-2.0.0-alpha.jar app.jar

# Copy config
COPY ./bbdata.properties /

# Expose port on host
EXPOSE 8080

## Launch the wait tool and then your application --spring.config.location=file:/bbdata.properties
CMD /wait && java -jar /app.jar 