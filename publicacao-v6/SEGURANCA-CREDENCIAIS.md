# Segurança: `CREDENCIAIS.md` no repositório privado (24/11)

## O que foi encontrado (e o que NÃO foi feito)
- `jraalves/sltweb-gestao-fiscal` (privado, 603 arquivos) contém `CREDENCIAIS.md` com
  senhas/postgres de ambiente. **Nada desse arquivo foi copiado** para os artefatos
  públicos, para o portfólio, para o case anonimizado ou para este sandbox de entrega.
- A varredura dos repositórios públicos (`leak_check` em 41 arquivos) não achou credencial,
  hostname interno, IP real, cliente ou número de produção.

## Por que isso importa para um perfil de SRE
Um recrutador técnico que encontre credencial em repositório — mesmo privado, com
colaborador, fork ou token — lê isso como "essa pessoa trata segredo como arquivo de
texto". É o único achado que derruba um perfil otherwise forte. Então: corrigir hoje,
não na próxima revisão.

## Ordem correta das ações (10 minutos)
1. **Rotacionar primeiro, apagar depois.** Senha que já esteve em Git deve ser tratada
   como comprometida, inclusive no histórico. Rotacione: senha do banco (postgres),
   senhas de ambiente listadas no arquivo e qualquer token/chave de API que apareça lá.
2. **Remover o arquivo** no branch principal:
   `sltweb-gestao-fiscal → CREDENCIAIS.md → lápis (Edit this file) → Delete file → Commit changes`
3. **Reescrever o histórico** se o repositório tem colaborador, fork ou foi espelhado:
   ```bash
   git filter-repo --path CREDENCIAIS.md --invert-remove --force
   git push --force --all && git push --force --tags
   ```
   (Sem `git filter-repo`: `pip install git-filter-repo`. Aviso: `--force` reescreve
   histórico — combine com quem clonou o repo antes de rodar.)
4. **Suporte do GitHub** só é necessário se o segredo foi público em algum momento:
   https://support.github.com/contact/secret-report — com o hash do commit.
5. **Substituir o arquivo por um modelo sem valor:** `CREDENCIAIS.example.md` com nomes
   de variáveis e `CHANGE_ME`, mais um `.gitignore` com `CREDENCIAIS*`, e o guard:
   ```bash
   pip install pre-commit && pre-commit install
   pre-commit run --all-files   # ou use o git-secret-guard deste perfil
   ```
6. **Renomear o repositório** para tirar a marca do cliente:
   `Settings → General → Repository name → ex.: gestao-fiscal-platform` (o GitHub
   redireciona links antigos; faça depois do passo 2 para não perder referência).
   Confirme que o nome novo não contém a marca do cliente.
7. **Preparação para produção (o que o arquivo sugere que ainda falta):** cofre de
   segredos (Vault / AWS Secrets Manager com rotação), `secrets:` nunca em YAML de
   aplicação, e `.env` fora do versionamento por padrão de projeto.

## O que o assistente pode fazer sozinho vs. o que precisa de você
| ação | por quê |
|---|---|
| apagar `CREDENCIAIS.md`, renomear o repo, ligar Pages, aplicar foto, pins | precisa de sessão autenticada no navegador: a integração não tem permissão de escrita em repositório pré-existente (`Resource not accessible by integration`) |
| rotacionar senhas | só você tem acesso ao ambiente |
| reescrever histórico com `filter-repo` | roda na sua máquina; exige `--force` na sua conta |
