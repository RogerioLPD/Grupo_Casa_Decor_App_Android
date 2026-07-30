# Checklist de Release

Use este checklist antes de atualizar o GitHub ou publicar uma nova versao.

## Antes do Commit

- [ ] Revisar `git status --short`.
- [ ] Confirmar que nao ha arquivos de build/cache versionados.
- [ ] Confirmar que nao ha chaves privadas, certificados sensiveis ou arquivos locais.
- [ ] Rodar `dart format .`.
- [ ] Rodar `flutter analyze`.
- [ ] Rodar `flutter test`.
- [ ] Testar login dos perfis principais: admin, empresa e especificador.
- [ ] Testar geracao de PDF nas listas alteradas.
- [ ] Testar tema claro e escuro.

## Build Web

- [ ] Rodar `flutter build web --release`.
- [ ] Validar a navegacao inicial da landing page.
- [ ] Validar rotas apos login.
- [ ] Publicar com `firebase deploy --only hosting`, quando aplicavel.

## Build Android

- [ ] Conferir `version` em `pubspec.yaml`.
- [ ] Rodar `flutter build appbundle --release`.
- [ ] Testar instalacao em dispositivo real ou emulador.

## GitHub

- [ ] Criar branch com nome claro.
- [ ] Abrir Pull Request com resumo objetivo.
- [ ] Incluir prints ou videos curtos quando houver mudanca visual.
- [ ] Conferir o CI antes de mergear.

## Observacoes

- Confirme que certificados como `upload_certificate.pem` nao aparecem em `git ls-files`.
- Arquivos `.firebase/hosting.*.cache` nao devem ser versionados; eles sao gerados pelo Firebase Hosting.
