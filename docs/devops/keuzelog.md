# Keuzelog DevOps

Elke keuze met het alternatief en de reden. Dit is de bron voor de onderbouwing in het beheersdocument.
Status "voorstel" betekent: technisch uitgevoerd, Pedro moet de reden nog bevestigen of aanpassen.

| # | Keuze | Alternatief | Reden | Status |
|---|---|---|---|---|
| K1 | Multi-stage Dockerfile: Flutter bouwt, nginx serveert | Webbuild in de pipeline maken en alleen kopiëren | De image bouwt zonder lokale Flutter. Iedereen krijgt hetzelfde resultaat | voorstel |
| K2 | Flutter vast op 3.44.9 in Dockerfile en pipeline | Kanaal `stable` | `stable` verandert ongemerkt. Het standaardimage (Dart 3.12.0) faalde op `pubspec.yaml` (vraagt ^3.12.2) | voorstel |
| K3 | `nginx-unprivileged` als basis, draait als uid 101 | Gewone `nginx` als root | Minder rechten bij een lek | voorstel |
| K4 | Goss niet in de image, maar van buitenaf met dgoss. HEALTHCHECK met `wget` | Goss in de image, zoals het lesvoorbeeld | Trivy vond 49 hoge kwetsbaarheden in de Goss-binary. Zonder Goss: 0 | voorstel |
| K5 | `apk upgrade` in de image | Basisimage zoals het is | Trivy vond 13 kwetsbaarheden in Alpine, waarvan 1 kritiek. Na de upgrade: 0 | voorstel |
| K6 | Trivy voor image en dependencies | CodeQL | CodeQL ondersteunt geen Dart. Trivy scant de image en `pubspec.lock` zonder account | voorstel |
| K7 | Coverage- en security-badge als JSON op GitHub Pages, via shields.io | Codecov | Geen extra account of token nodig | voorstel |
| K8 | Eén workflow `pipeline.yml` in plaats van `ci.yml` + `deploy.yml` | Twee losse workflows | De deploy wachtte niet op de tests. Nu alleen deployen als alles slaagt | voorstel |
| K9 | Pipeline stopt bij een kritieke kwetsbaarheid waarvoor een fix bestaat | Alleen rapporteren | Geen bekende, oplosbare lekken naar productie | voorstel |
| K11 | trivy-action vastgezet op een commit in plaats van een versie-tag | `@v0.36.0` of `@master` | In maart 2026 zijn de tags van deze action gekaapt (GHSA-69fq-xp46-6x23). Een commit kan niet worden omgehangen | voorstel |
| K10 | Coverage minimaal 60% | Geen drempel | Huidige stand 66,5%. De drempel voorkomt dat het ongemerkt zakt | voorstel |
| K12 | Release naar GitHub Container Registry (GHCR) | Docker Hub | Inloggen met het `GITHUB_TOKEN` van de pipeline. Geen extra account of secret nodig. Tags volgens de les: `latest` voor `main`, een versie-tag bij `v*` | voorstel |
| K13 | De release pusht de image die Goss en Trivy hebben getest | Opnieuw bouwen in de release-job | Wat in de registry staat is precies wat getest is | voorstel |
| K14 | GitHub Pages haalt de site uit de image in GHCR | Flutter opnieuw bouwen voor Pages | Zo wordt de release zelf gedeployed. Alleen de `<base href>` wordt aangepast. Lokaal gecontroleerd (24-11): een build met `--base-href /devopsWindesheim/` verschilt verder alleen in de service-worker-versie | voorstel |
| K15 | Omgeving `production` op de release-job, alleen vanaf `main` of een versie-tag | Ook een `staging`-omgeving op `dev` | Er is nu geen `dev`-tak in deze repo. Pull requests draaien test, build en security, maar releasen en deployen niet | voorstel |

## Meetwaarden (lokaal gemeten op 19-11-2026)

| Meting | Voor | Na |
|---|---|---|
| Trivy hoog/kritiek in de image | 62 (13 Alpine, 49 Goss-binary) | 0 |
| Trivy hoog/kritiek in `pubspec.lock` | 0 | 0 |
| Coverage (regels) | 66,5% (1392 van 2092), over 38 van de 39 bestanden in `lib/` (`main.dart` laadt geen test) | |
| Unit- en widgettests | 155, allemaal groen | |
| Goss-tests | 7, allemaal groen | |
