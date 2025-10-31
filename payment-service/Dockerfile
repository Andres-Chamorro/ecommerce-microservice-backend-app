FROM eclipse-temurin:17-jre
WORKDIR /app
COPY payment-service/target/payment-service-v0.1.0.jar app.jar
EXPOSE 8300
ENTRYPOINT ["java", "-jar", "app.jar"]
