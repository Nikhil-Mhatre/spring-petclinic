# Stage 1: Build the application using Maven
# We use an official Maven image that has JDK 25 included
FROM maven:3.9-eclipse-temurin-25 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy just the pom.xml first to leverage Docker layer caching
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code and build the application
COPY src ./src
RUN mvn clean package

# Stage 2: Create the final, lightweight runtime image
# We use an official Java 25 runtime image
FROM eclipse-temurin:25-jre-jammy

# Set the working directory
WORKDIR /app

# Copy the built .jar file from the 'build' stage
COPY --from=build /app/target/spring-petclinic-*.jar app.jar

# Expose port 8080 (the default for Spring Boot)
EXPOSE 8080

# The command to run when the container starts
ENTRYPOINT ["java", "-jar", "app.jar"]
