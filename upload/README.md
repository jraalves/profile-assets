# Definições de pipeline versionadas

Cada arquivo aqui é o YAML **exato** que escrevi para um repositório público deste perfil.
Eles ficam fora de `.github/workflows/` porque a integração usada nesta revisão de publicação
não recebeu permissão para escrever `.github/` — então em vez de um selo verde que não roda,
publico a definição completa, legível, com gatilho, jobs e checagens.

Para ativar em qualquer repositório:

```bash
cp <este-arquivo> .github/workflows/<nome>.yml   # GitHub Actions
git add .github/workflows && git commit -m "ci: ativar pipeline"
```

| arquivo | repo | gatilhos | o que checa |
|---|---|---|---|
| `sre-senior-lab--labs.yml` | `sre-senior-lab` | `push`, `pull_request`, `workflow_dispatch` | lint, testes unitários, `make ci` |
| `observability-golden-signals-stack--ci.yml` | `observability-golden-signals-stack` | `push`, `pull_request` | regras de golden signals, tags, estatísticas, telemetria |
| `sre-aiops-agent-reference--ci.yml` | `sre-aiops-agent-reference` | `pull_request` | contratos do referencial de agentes de diagnóstico |
| `otel-correlation-design--ci.yml` | `otel-correlation-design` | `push` | coerência do desenho de correlação trace↔log |
| `git-secret-guard--ci.yml` | `git-secret-guard` | `push`, `pull_request` | detecção de credencial em diff, testes do guard |

Nenhum segredo é lido por essas definições: todos os checadores operam sobre código e fixtures
sintéticas, com `secrets: {}` implícito (nenhum `secrets.` no YAML).
