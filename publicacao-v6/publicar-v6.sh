#!/usr/bin/env bash
# =====================================================================
# publicar-v6.sh  —  aplica o README de perfil v6 e o portfolio v6 no GitHub
#
# Por que este script existe: a integracao (GitHub App) usada pelo
# assistente consegue CRIAR repositorios e fazer push neles, mas o GitHub
# nega ESCREVER em repositorios que ja existiam (jraalves/jraalves e
# jraalves/portfolio): "Resource not accessible by integration" /
# "Permission ... denied". Com um token seu (Personal Access Token classico
# com escopo `repo`) a mesma escrita funciona normalmente.
#
# Como obter o token (30 segundos):
#   https://github.com/settings/tokens/new?scopes=repo,workflow,read:user
#   -> Generate token -> copie o valor (comeca com "ghp_")
#
# Uso (Linux/macOS/WSL/Git Bash no Windows):
#   export GH_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
#   bash publicar-v6.sh
#
# NAO faz nada destrutivo: nao apaga repositorio, nao apaga historico,
# nao toca em arquivos privados, nao publica segredo. Se faltar Pages,
# o script avisa exatamente onde ligar.
# =====================================================================
set -euo pipefail

: "${GH_TOKEN:?defina GH_TOKEN com um PAT classico (escopos: repo, workflow)}"
BASE="$(cd "$(dirname "$0")" && pwd)"
NAME="${GIT_NAME:-Joao Renato Alves}"
EMAIL="${GIT_EMAIL:-160369727+jraalves@users.noreply.github.com}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
G() { curl -sS -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github+json" "$@"; }
ok() { printf '\n==> %s\n' "$*"; }

# ------------------------------------------------------------- funcao
apply() {  # apply <repo> <arquivo_local> <caminho_no_repo> <msg>
  local R=$1 SRC=$2 DST=$3 MSG=$4
  [ -f "$SRC" ] || { echo "FALTA o arquivo: $SRC"; exit 1; }
  ok "$R: $DST  <- $(basename "$SRC") ($(wc -c < "$SRC") bytes)"
  local D="$WORK/$R"
  git clone -q --depth 1 "https://oauth2:${GH_TOKEN}@github.com/jraalves/${R}.git" "$D"
  mkdir -p "$(dirname "$D/$DST")"; cp "$SRC" "$D/$DST"
  git -C "$D" add "$DST"
  if git -C "$D" diff --cached --quiet; then echo "   sem alteracoes"; return 0; fi
  git -C "$D" -c user.name="$NAME" -c user.email="$EMAIL" commit -q -m "$MSG"
  git -C "$D" push -q origin HEAD:main
  echo "   publicado: $(git -C "$D" rev-parse --short HEAD)"
}

# --------------------------------------------------- 1) README do perfil
apply jraalves "$BASE/README-perfil-v6.md" README.md \
  "docs(perfil): v6 - cronologia estrita do CV (2013->2026), metricas medidas, claims de CI honestos"

# --------------------------------------------------- 2) portfolio
apply portfolio "$BASE/portfolio-v6-index.html" index.html \
  "docs(portfolio): v6 - mesma base factual do perfil; timeline do CV; CI descrito como definicao versionada"

# --------------------------------------------------- 3) GitHub Pages
pages() {  # pages <repo>
  local R=$1 code
  code=$(G -o /dev/null -w '%{http_code}' "repos/jraalves/$R/pages")
  if [ "$code" = "200" ]; then echo "   $R: Pages ja ligado"; return 0; fi
  G -X POST "repos/jraalves/$R/pages" \
     -H "Content-Type: application/json" \
     -d '{"source":{"branch":"main","path":"/"}}' >/dev/null && \
     echo "   $R: Pages ligado em main /(raiz)" || \
     echo "   $R: FALHOU ligar Pages -> ligue em Settings > Pages > Deploy from a branch > main / (root)"
}
ok "GitHub Pages"
pages portfolio
pages automacao

# --------------------------------------------------- 4) topics
ok "Topics do repo do case, se existirem"
for R in sre-senior-lab observability-golden-signals-stack automacao; do
  G -X PUT "repos/jraalves/$R/topics" -H "Content-Type: application/json" \
    -d '{"names":["sre","observability","python","gitops","runbooks"]}' >/dev/null 2>&1 \
    && echo "   $R: topics ok" || echo "   $R: topics nao aplicados"
done

ok "Verificacao final"
for U in \
  "https://jraalves.github.io/portfolio/" \
  "https://jraalves.github.io/automacao/" \
  "https://raw.githubusercontent.com/jraalves/jraalves/main/README.md" ; do
  C=$(curl -s -o /dev/null -w '%{http_code}' -L "$U"); echo "   $C  $U"
done
if [ "${C:-0}" = "200" ]; then
  N2009=$(curl -sL "https://raw.githubusercontent.com/jraalves/jraalves/main/README.md" | grep -c 2009 || true)
  echo "   ocorrencias de '2009' no README publicado: $N2009 (esperado: 0)"
fi

echo
echo "AINDA MANUAL (so a interface web faz):"
echo "  - foto do perfil: Settings > Profile > Photo (upload)  [+ faca Ctrl+F5 para limpar o cache]"
echo "  - repositorios fixados (pins): Overview > Customize your pins > maximo 6"
echo "  - se aparecer challenge de senha do GitHub, e so digitar no navegador"
echo
echo "Pronto."
