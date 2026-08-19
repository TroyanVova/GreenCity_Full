# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -Dformatter.skip=true -pl core -am

# ---- Run stage ----
FROM eclipse-temurin:21-jre
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/core/target/core.jar app.jar
EXPOSE 8060
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=docker"]
