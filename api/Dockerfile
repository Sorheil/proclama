
# ============================================================
# ETAPE 1 : BUILD - Compilation de l'application Spring Boot
# ============================================================

ARG MAVEN_IMAGE=maven:3.9-eclipse-temurin-21-alpine
ARG JRE_IMAGE=eclipse-temurin:21-jre-alpine

FROM ${MAVEN_IMAGE} AS build

WORKDIR /build

# Copier le pom.xml en premier pour optimiser le cache Docker
COPY pom.xml .

# Télécharger les dépendances Maven
RUN mvn -B -q dependency:go-offline

# Copier le code source
COPY src ./src

# Compiler et générer le JAR sans exécuter les tests
RUN mvn -B -q package -DskipTests


# ============================================================
# ETAPE 2 : RUNTIME - Exécution de l'application
# ============================================================

FROM ${JRE_IMAGE} AS runtime

WORKDIR /app

# Version de l'application
ARG APP_VERSION=dev

# Installer Tini pour gérer correctement les processus
RUN apk add --no-cache tini

# Créer un utilisateur non privilégié (UID 10001)
RUN addgroup -S -g 10001 app \
    && adduser -S -D -H -u 10001 -G app app

# Copier le JAR et le script d'entrée
COPY --from=build --chown=app:app /build/target/proclama-api.jar /app/app.jar
COPY --chown=app:app docker/entrypoint.sh /app/entrypoint.sh

# Rendre le script exécutable
RUN chmod 755 /app/entrypoint.sh

# Variables d'environnement
ENV PORT=8080 \
    APP_VERSION=${APP_VERSION} \
    SPRING_PROFILES_ACTIVE=prod \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=55 -XX:+UseSerialGC -XX:MaxDirectMemorySize=4g -Xss512k"

# Métadonnées de l'image
LABEL org.opencontainers.image.title="proclama-api" \
      org.opencontainers.image.version="${APP_VERSION}"

# Port utilisé par l'API
EXPOSE 8080

# Vérification de l'état de santé de l'API
HEALTHCHECK --interval=15s --timeout=3s --start-period=60s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/api/health || exit 1

# Exécuter l'application sans privilèges root
USER app

# Tini gère les signaux et les processus enfants
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]

# Commande par défaut
CMD ["java", "-jar", "app.jar"]
