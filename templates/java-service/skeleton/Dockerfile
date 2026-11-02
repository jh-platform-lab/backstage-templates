# Imagen para Kubernetes (EKS). Para Lambda ver Dockerfile.lambda.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
# El pom va antes que el codigo para reutilizar la capa de dependencias.
COPY pom.xml ./
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /srv
COPY --from=build /src/target/app.jar app.jar
# Usuario numerico para que Kubernetes pueda verificar runAsNonRoot.
USER 10001:10001
EXPOSE 8000
# Las sondas /health las hace Kubernetes (la imagen no trae curl, asi que no hay HEALTHCHECK de Docker).
# Contenedor con limite de memoria: la JVM dimensiona el heap segun el limite.
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
