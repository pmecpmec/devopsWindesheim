# Stap 1: de Flutter-webversie bouwen
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS build
# Dezelfde Flutter-versie als lokaal en in pipeline.yml; het basisimage loopt achter
ARG FLUTTER_VERSION=3.44.9
RUN git -C /sdks/flutter fetch --depth 1 origin tag ${FLUTTER_VERSION} \
    && git -C /sdks/flutter checkout -q ${FLUTTER_VERSION} \
    && flutter --version
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stap 2: alleen de gebouwde bestanden serveren met nginx, zonder root
FROM nginxinc/nginx-unprivileged:alpine AS final
USER root
# Beveiligingsupdates van het basisimage meenemen; Trivy in de pipeline controleert dit
RUN apk upgrade --no-cache
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
USER 101
EXPOSE 8080
# Goss zit bewust niet in de image (minder kwetsbaarheden); de pipeline draait Goss van buitenaf met dgoss
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8080/health || exit 1
