# Teamplanner

[![Pipeline](https://github.com/pmecpmec/devopsWindesheim/actions/workflows/pipeline.yml/badge.svg?branch=main)](https://github.com/pmecpmec/devopsWindesheim/actions/workflows/pipeline.yml)
[![Coverage](https://img.shields.io/endpoint?url=https://pmecpmec.github.io/devopsWindesheim/badges/coverage.json)](https://github.com/pmecpmec/devopsWindesheim/actions/workflows/pipeline.yml)
[![Kwetsbaarheden](https://img.shields.io/endpoint?url=https://pmecpmec.github.io/devopsWindesheim/badges/security.json)](https://github.com/pmecpmec/devopsWindesheim/security/code-scanning)

Flutter-app voor teams, events, matches, QR-uitnodigingen en een routeplanner. Draait op web en Android.
De back-end is een bestaande REST-API. De app komt uit het vak Cross-Platform Development (repo `pmecpmec/CPD`); deze repo voegt de DevOps-pipeline toe.

Live: https://pmecpmec.github.io/devopsWindesheim/

## Lokaal draaien

Met Flutter 3.44.9:

```sh
flutter pub get
flutter test
flutter run -d chrome
```

Met Docker (geen Flutter nodig):

```sh
docker build -t teamplanner .
docker run -p 8080:8080 teamplanner
```

Of de laatste release uit de registry, zonder zelf te bouwen:

```sh
docker run -p 8080:8080 ghcr.io/pmecpmec/devopswindesheim:latest
```

Daarna draait de app op http://localhost:8080. De healthcheck staat op `/health`.

## Pipeline

`.github/workflows/pipeline.yml` draait bij elke push en pull request op `main` en `dev`:

1. **Analyse en tests**: formattering, `flutter analyze`, tests met coverage (minimaal 60%)
2. **Build**: webversie, Android-APK en Docker-image
3. **Infrastructuurtests**: HEALTHCHECK van de container en Goss-tests met dgoss
4. **Security**: Trivy scant de image en de dependencies. Bij een kritieke kwetsbaarheid met fix stopt de pipeline
5. **Release**: alleen bij een push naar `main` of een versie-tag (`v*`). De geteste image gaat naar `ghcr.io/pmecpmec/devopswindesheim` met de tags `latest` en `sha-<commit>`. Een versie-tag krijgt ook een GitHub Release
6. **Deploy**: alleen bij een push naar `main`. GitHub Pages krijgt de site uit de image in de registry
