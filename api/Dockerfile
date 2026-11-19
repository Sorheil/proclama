# Image de l'API (et du worker : même image, commande différente).
ARG MAVEN_IMAGE=maven:3.9-eclipse-temurin-21-alpine
ARG JRE_IMAGE=eclipse-temurin:21-jre-alpine

# ---------- Étape 1 : compilation ----------
FROM ${MAVEN_IMAGE} AS build
WORKDIR /src
# pom.xml d'abord : le téléchargement des dépendances reste en cache tant que le pom ne change pas.
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---------- Étape 2 : image finale (JRE seul) ----------
FROM ${JRE_IMAGE} AS runtime
ARG APP_VERSION=dev
# tini : processus 1 propre (relais des signaux, pas de zombies). Utilisateur non-root.
RUN apk add --no-cache tini && addgroup -S app && adduser -S -G app -u 10001 app
WORKDIR /app
COPY --from=build --chown=app:app /src/target/proclama-api.jar ./app.jar
COPY --chown=app:app --chmod=755 docker/entrypoint.sh ./entrypoint.sh
USER app
# SPRING_PROFILES_ACTIVE=prod : active application-prod.yml (placeholders remplis par les variables du conteneur).
ENV PORT=8080 APP_VERSION=${APP_VERSION} SPRING_PROFILES_ACTIVE=prod \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=55 -XX:+UseSerialGC -XX:MaxDirectMemorySize=4g -Xss512k"
EXPOSE 8080
LABEL org.opencontainers.image.title="proclama-api" \
      org.opencontainers.image.version="${APP_VERSION}"
HEALTHCHECK --interval=15s --timeout=3s --start-period=60s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/api/health || exit 1
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["java", "-jar", "app.jar"]
