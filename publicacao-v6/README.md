# Publicacao v6 (24/11) — pronta para aplicar

Estes arquivos sao a versao **v6** do README de perfil e do index do portfolio: as datas da
cronologia vem literalmente do CV (jan/2013 -> abr/2026, 14 periodos), as metricas sao as
medidas nos laboratorios (94,94% de acerto de categoria e 79,75% de escolha de runbook sob
perturbacao; 100% intra-amostra declarado como overfit) e nao existe nenhuma frase dizendo
que um pipeline roda onde ele nao roda.

Por que estao aqui e nao direto no repositorio do perfil: a integracao usada pelo assistente
consegue criar repositorio e fazer push no que ela criou, mas o GitHub nega escrita em
`jraalves/jraalves` e `jraalves/portfolio` (`Resource not accessible by integration`). Sobra
dois caminhos: navegador logado na sua conta, ou `publicar-v6.sh` com um PAT seu.

```bash
export GH_TOKEN=ghp_seu_token_aqui      # escopos: repo, workflow
bash publicar-v6.sh
```

O que o script faz: aplica os dois arquivos, liga GitHub Pages em `main`/(raiz) de
`portfolio` e `automacao`, reaplica topics e imprime a verificacao (HTTP 200 e contagem de
"2009" esperado 0). O que ele **nao** faz: apagar repositorio, apagar historico, tocar em
repositorio privado, publicar segredo, marcar "open to work".
