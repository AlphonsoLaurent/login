# Etapa 1: Compilar la aplicación con Gradle
FROM gradle:7.6.2-jdk17 AS build

WORKDIR /login

# Copiar archivos de configuración y código fuente
COPY build.gradle settings.gradle ./
COPY src ./src

# Compilar la aplicación
RUN gradle clean bootJar --no-daemon

# Etapa 2: Crear la imagen final con OpenJDK
FROM openjdk:17-jdk-alpine

WORKDIR /login

# Copiar el JAR compilado desde la etapa anterior
COPY --from=build /login/build/libs/login-0.0.1-SNAPSHOT.jar login-0.0.1-SNAPSHOT.jar

# Exponer el puerto 8080
EXPOSE 8080

# Ejecutar la aplicación Spring Boot
ENTRYPOINT ["java", "-jar", "login-0.0.1-SNAPSHOT.jar"]