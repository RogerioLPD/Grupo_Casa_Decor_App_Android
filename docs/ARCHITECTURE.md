# Arquitetura

O projeto usa uma arquitetura orientada a funcionalidades. Cada fluxo de
negocio fica em um modulo proprio, independentemente de ser exibido na web ou
no mobile.

## Estrutura

```text
lib/
  main.dart
  app/
    app.dart
    routes.dart
  core/
    theme/
    utils/
  features/
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
    presentation/
      widgets/
```

## Responsabilidades

### `main.dart`

Ponto de entrada minimo. Inicializa o Flutter, os dados de localizacao e o
escopo global do Riverpod.

### `app`

Concentra a composicao global:

- `app.dart`: configura `MaterialApp`, localizacoes, tema e resolucao de rotas.
- `routes.dart`: define nomes de rotas e transicoes.

### `core`

Codigo de infraestrutura que nao pertence a uma funcionalidade:

- `theme`: tema claro, tema escuro, cores e tipografia.
- `utils`: funcoes utilitarias sem estado ou dependencia de telas.

### `features`

Cada pasta representa uma capacidade do produto:

- `admin`: painel, cadastro de empresas e cadastro de premios.
- `auth`: login, cadastro e verificacao de sessao.
- `companies`: catalogo e dados das empresas parceiras.
- `company`: area da empresa logada, pontos, atividades e extrato.
- `landing`: pagina publica e suas secoes.
- `legal`: termos de uso e politica de privacidade.
- `onboarding`: splash e apresentacao inicial do aplicativo.
- `profile`: perfil compartilhado pelos diferentes tipos de usuario.
- `reports`: relatorios, ranking e geracao de PDF.
- `rewards`: premios, resgate e componentes relacionados.
- `specifier`: experiencia mobile, pontos e transacoes do especificador.

Uma feature pode usar as seguintes camadas:

```text
feature/
  data/
    models/
    providers/
    services/
  presentation/
    pages/
    sections/
    widgets/
```

`data` concentra modelos, estado e acesso a API. `presentation` concentra
widgets Flutter. Pastas vazias nao devem ser criadas apenas para completar o
modelo.

### `shared`

Contem somente componentes reutilizados por mais de uma feature. Um widget
especifico de uma funcionalidade deve permanecer dentro dela.

## Regra de Dependencias

O fluxo esperado e:

```text
main -> app -> features -> core/shared
```

- `core` nao depende de features.
- `shared` nao deve conter regras de negocio de uma feature.
- Uma feature pode consumir outra quando existe uma relacao real de produto,
  como o dashboard da empresa consumindo relatorios.
- Dependencias circulares entre features devem ser evitadas.
- Imports internos devem usar o formato
  `package:nucleo_casa_decor_android/...`.

## Fluxos Principais

### Web Publica

```text
main -> app -> landing -> sections
```

### Web Administrador

```text
auth -> admin_home -> dashboard/cadastros/reports/profile
```

### Web Empresa

```text
auth -> company_home -> company_dashboard/points/profile
```

### Mobile Especificador

```text
onboarding/auth -> specifier_navigation
                       |
                       +-> home/transactions/companies/rewards/profile
```

## Convencoes

- Arquivos usam `snake_case`.
- Paginas terminam em `_page.dart`.
- Widgets reutilizaveis ficam em arquivos proprios.
- Controllers de API ficam em `data/services`.
- Providers ficam em `data/providers`.
- Modelos ficam em `data/models`.
- Formatacao de moeda, data e pontos usa `intl` com locale `pt_BR`.
- Exportacoes PDF ficam em
  `features/reports/data/services/pdf_export_service.dart`.

## Evolucao

A estrutura fisica ja esta separada por feature. Algumas telas legadas ainda
fazem chamadas HTTP diretamente; novas implementacoes devem colocar essa
logica em `data/services`, e telas existentes podem ser migradas
incrementalmente quando forem alteradas.

## Limpeza Realizada

Foram removidos arquivos sem referencias ativas:

- `shared/screens/login_company.dart`
- `mobile/screens/update_especifier.dart`
- `web/screens/profile_screen.dart`
- `web/landing.dart`
- `shared/services/teste.dart`

A tela de ranking permanece registrada em rota e nao deve ser removida sem
confirmar se existe acesso direto por URL.
