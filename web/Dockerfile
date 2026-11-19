# syntax=docker/dockerfile:1
# Image du web : build Angular (Node) puis service des fichiers statiques (nginx).
ARG NODE_IMAGE=node:22-alpine
ARG NGINX_IMAGE=nginx:1.28-alpine

# ---------- Étape 1 : compilation ----------
FROM ${NODE_IMAGE} AS build
WORKDIR /src
# Les dépendances d'abord : cette couche reste en cache tant que package*.json ne change pas.
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npx ng build --configuration production

# ---------- Étape 2 : image finale (sans Node) ----------
FROM ${NGINX_IMAGE} AS runtime
ARG APP_VERSION=dev
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/dist/proclama-web/browser /usr/share/nginx/html
LABEL org.opencontainers.image.title="proclama-web" \
      org.opencontainers.image.version="${APP_VERSION}"
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
