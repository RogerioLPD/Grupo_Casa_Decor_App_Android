# Grupo Casa Decor App

Aplicativo Flutter do programa de pontos do Grupo Casa Decor, com interfaces para web e mobile.

## Visao Geral

O projeto atende tres fluxos principais:

- Landing page web para apresentacao do programa.
- Painel administrativo web para cadastro de empresas, premios e relatorios.
- Area da empresa web para lancamento de pontos, dashboard e extrato.
- Experiencia mobile para especificadores acompanharem pontos, transacoes, empresas parceiras e premios.

## Tecnologias

- Flutter 3.32.7
- Dart SDK 3.7+
- Riverpod para estado em telas web
- HTTP para integracao com a API
- PDF/Printing para relatorios em PDF
- Intl e localizacoes Flutter para formatos pt-BR
- Firebase Hosting para publicacao web

## Estrutura

```text
lib/
  main.dart                  # Bootstrap minimo da aplicacao
  app/                       # MaterialApp e rotas globais
  core/                      # Tema e utilitarios sem regra de negocio
  features/                  # Modulos organizados por funcionalidade
    admin/
    auth/
    companies/
    company/
    landing/
    legal/
    onboarding/
    profile/
    reports/
    rewards/
    specifier/
  shared/
    presentation/widgets/    # Widgets usados por mais de um modulo
docs/                        # Documentacao tecnica do projeto
test/                        # Testes automatizados
```

Cada feature pode conter `data`, `presentation/pages`,
`presentation/sections` e `presentation/widgets`, conforme sua necessidade.
Mais detalhes estao em [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Como Rodar

Instale as dependencias:

```bash
flutter pub get
```

Rode no navegador:

```bash
flutter run -d chrome
```

Rode em dispositivo/emulador mobile:

```bash
flutter run
```

## Qualidade

Antes de abrir PR ou atualizar o GitHub, execute:

```bash
dart format .
flutter analyze
flutter test
```

O projeto deve permanecer sem avisos no `flutter analyze`. Novas alteracoes devem incluir validacao local antes do commit.

## Build Web

```bash
flutter build web --release
```

Publicacao Firebase Hosting:

```bash
firebase deploy --only hosting
```

## Build Android

```bash
flutter build apk --release
```

ou:

```bash
flutter build appbundle --release
```

## Preparacao Para GitHub

Use o checklist em [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md) antes de atualizar o repositorio.

Arquivos de build, cache, configuracoes locais e certificados nao devem ser publicados. Revise sempre o resultado de:

```bash
git status --short
git diff --stat
```

## Observacoes de Seguranca

- Tokens de usuario sao armazenados localmente via `shared_preferences`.
- Endpoints da API estao no codigo e devem ser revisados antes de qualquer mudanca de ambiente.
- Nao versionar chaves privadas, certificados sensiveis, `local.properties`, `key.properties`, builds ou caches.
