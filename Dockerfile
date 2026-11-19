# Stap 1: de Flutter-webversie bouwen
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS build
# Dezelfde Flutter-versie als lokaal en in de pipeline; het basisimage loopt achter
ARG FLUTTER_VERSION=3.44.9
RUN git -C /sdks/flutter fetch --depth 1 origin tag ${FLUTTER_VERSION}     && git -C /sdks/flutter checkout -q ${FLUTTER_VERSION}     && flutter --version
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stap 2: alleen de gebouwde bestanden serveren met nginx, zonder root
FROM nginxinc/nginx-unprivileged:alpine AS final
ARG TARGETARCH=amd64
# v0.4.9: laatste versie met losse binaries per architectuur (v0.4.10 levert tarballs)
ARG GOSS_VERSION=v0.4.9
USER root
RUN wget -qO /usr/local/bin/goss \
      "https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}/goss-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/goss
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY .goss/goss.yaml /goss/goss.yaml
COPY --from=build /app/build/web /usr/share/nginx/html
USER 101
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD goss -g /goss/goss.yaml validate --format tap || exit 1
