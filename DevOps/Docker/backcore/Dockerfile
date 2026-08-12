FROM maven:3.9.7-eclipse-temurin-21 AS builder

WORKDIR /app

COPY apps/backcore/ ./

RUN mvn formatter:format && mvn clean package -DskipTests



FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Якщо проєкт багатомодульний і jar збирається не в /app/target/, поправ шлях нижче
COPY --from=builder /core/target/*.jar core.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "core.jar"]
