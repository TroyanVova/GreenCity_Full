FROM maven:3.9.7-eclipse-temurin-21 AS builder

WORKDIR /app

COPY apps/backcore/ ./

RUN mvn formatter:format && mvn clean package -DskipTests



FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/core/target/*.jar core.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "core.jar"]
