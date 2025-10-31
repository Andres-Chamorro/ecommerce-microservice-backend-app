FROM eclipse-temurin:17-jre
WORKDIR /app
COPY favourite-service/target/favourite-service-v0.1.0.jar app.jar
EXPOSE 8300
ENTRYPOINT ["java", "-jar", "app.jar"]
