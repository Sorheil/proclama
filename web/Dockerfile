
ARG NODE_IMAGE=node:22-alpine
ARG NGINX_IMAGE=nginx:1.28-alpine

# Première étape : construire Angular
FROM ${NODE_IMAGE} AS build

WORKDIR /app

# Installer les dépendances
COPY package.json package-lock.json ./
RUN npm ci

# Copier le reste du code source
COPY . .

# Compiler l'application Angular
RUN npx ng build --configuration production

# Deuxième étape : servir Angular avec Nginx
FROM ${NGINX_IMAGE}

ARG APP_VERSION=dev

LABEL org.opencontainers.image.title="proclama-web"
LABEL org.opencontainers.image.version="${APP_VERSION}"

# Copier la configuration Nginx
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers Angular compilés
COPY --from=build /app/dist/proclama-web/browser /usr/share/nginx/html

# Port utilisé par Nginx
EXPOSE 8080

# Vérifier régulièrement que le serveur fonctionne
HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
