# Contribuindo

## Fluxo de Trabalho

1. Crie uma branch a partir da branch principal.
2. Mantenha a mudanca pequena e focada.
3. Rode validacoes locais antes do commit.
4. Abra um Pull Request usando o template do repositorio.

## Padroes

- Use `dart format` antes de commitar.
- Evite misturar refatoracao com mudanca funcional.
- Adicione codigo no modulo correspondente em `lib/features`.
- Mantenha acesso a dados, modelos e providers dentro de `data`.
- Mantenha paginas, secoes e widgets dentro de `presentation`.
- Use `lib/shared` apenas quando o componente for reutilizado por mais de uma feature.
- Use `lib/core` somente para infraestrutura sem regra de negocio.
- Prefira imports absolutos com `package:nucleo_casa_decor_android/...`.
- Nao versionar credenciais, certificados privados, caches ou builds.

## Validacao Local

```bash
dart format .
flutter analyze
flutter test
```

## Pull Requests

O PR deve informar:

- O que mudou.
- Como foi testado.
- Prints ou videos quando houver alteracao visual.
- Riscos ou pontos que precisam de revisao manual.
