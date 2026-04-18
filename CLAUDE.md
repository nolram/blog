# nolram blog — guia para LLMs

Blog pessoal em Hugo com tema Blowfish. Deploy automático via GitHub Actions para GitHub Pages em blog.nolram.dev.

## Stack

- **Hugo** 0.160.1+ Extended (obrigatório — versão standard não compila o tema)
- **Tema** Blowfish v2 instalado como Hugo Module (não submodule)
- **Deploy** GitHub Actions → GitHub Pages
- **Domínio** blog.nolram.dev via Cloudflare

## Seções de conteúdo

| Seção | Slug | Uso |
|---|---|---|
| Astrofotografia | `/astrophotography` | Imagens astronômicas com metadados de captura |
| Projetos | `/projects` | Projetos técnicos, homelab, desenvolvimento |
| Misc | `/misc` | Livros, viagens, pensamentos gerais |

## Como criar um novo post

```bash
# Astrofotografia (usa archetype com metadados de captura)
hugo new astrophotography/nome-do-objeto/index.md

# Projeto técnico
hugo new projects/nome-do-projeto/index.md

# Misc
hugo new misc/nome-do-post/index.md
```

O archetype preenche o frontmatter automaticamente com `draft: true` e todos os campos relevantes.

## Estrutura de um post (Page Bundle)

Sempre use Page Bundle — uma pasta com `index.md` e as imagens juntas:

```
content/astrophotography/
  ngc7000-nebula-america/
    index.md          ← conteúdo + frontmatter
    ngc7000.jpg       ← imagem de capa (referenciada em cover.image)
    ngc7000-crop.jpg  ← imagens adicionais usadas no corpo
```

Referência de imagem dentro do post: `![Legenda](ngc7000-crop.jpg)` (caminho relativo).

## Frontmatter por seção

### astrophotography
```yaml
---
title: "NGC 7000 — Nebulosa América do Norte"
date: 2026-04-10T22:00:00-03:00
draft: false                        # remover draft para publicar
description: "Resumo de uma linha"
tags: ["nebulosa", "cygnus"]
categories: ["astrophotography"]
equipment:
  telescope: "William Optics RedCat 51"
  camera: "ZWO ASI2600MM Pro"
  mount: "Sky-Watcher EQ6-R Pro"
  filters: ["Antlia Ha 3nm"]
capture:
  date: "2026-03-28"
  location: "Aiuruoca - MG"
  frames: 120
  exposure: "120s"
  total_integration: "4h 00m"
  bortle: 3
cover:
  image: "ngc7000.jpg"
  alt: "NGC 7000 em narrowband"
---
```

### projects
```yaml
---
title: "Nome do Projeto"
date: 2026-04-05T10:00:00-03:00
draft: false
description: "Resumo de uma linha"
tags: ["docker", "linux"]
categories: ["projects"]
tech_stack: ["Docker", "Ansible"]
github: "https://github.com/nolram/repo"
status: "completed"   # completed | in-progress | abandoned
cover:
  image: "capa.jpg"
  alt: "Descrição da imagem"
---
```

### misc
```yaml
---
title: "Título do Post"
date: 2026-01-03T09:00:00-03:00
draft: false
description: "Resumo de uma linha"
tags: ["livros"]
categories: ["misc"]
---
```

## Publicar um post (rascunho → publicado)

1. Abrir o `index.md` do post
2. Remover a linha `draft: true` (ou mudar para `draft: false`)
3. Confirmar que `date` está correto
4. Commit e push:

```bash
git add content/
git commit -m "post: título do post"
git push
```

O GitHub Actions faz build e deploy automaticamente (~1-2 min).

## Por que drafts não aparecem em produção

`draft: true` exclui o post do build de produção (`hugo --minify`). Localmente, `hugo server -D` os inclui. No site publicado, só posts sem draft aparecem.

## Rodar localmente

```bash
hugo server -D        # inclui drafts, live reload em localhost:1313
hugo server           # apenas posts publicados (simula produção)
```

## Configuração do tema

Arquivos relevantes:
- `hugo.toml` — configuração base Hugo
- `config/_default/params.toml` — opções visuais do Blowfish
- `config/_default/languages.pt-br.toml` — título, autor, bio, links sociais
- `config/_default/menus.pt-br.toml` — menu de navegação

### Adicionar link social ao autor

Em `config/_default/languages.pt-br.toml`:
```toml
[params.Author]
  links = [
    { github = "https://github.com/nolram" },
    { twitter = "https://twitter.com/nolram" },
    { email = "mailto:voce@email.com" }
  ]
```

Ícones suportados pelo Blowfish: github, twitter, instagram, linkedin, youtube, twitch, mastodon, email, rss, e outros — ver docs em blowfish.page/docs/configuration/.

## Adicionar imagem de perfil

1. Colocar foto em `assets/img/author.jpg` (ou `static/img/author.jpg`)
2. Em `config/_default/languages.pt-br.toml`:
   ```toml
   [params.Author]
     image = "img/author.jpg"
   ```

## Organização de imagens por post

- Imagens ficam dentro da pasta do post (Page Bundle)
- Não usar `/static/` para imagens de posts — use Page Bundle
- `/static/` é apenas para arquivos globais (CNAME, favicon, etc.)

## Deploy e CI/CD

- Push para `main` → GitHub Actions dispara automaticamente
- Build: `hugo --minify` com Hugo Extended 0.160.1
- Artifact enviado para GitHub Pages
- URL: https://blog.nolram.dev

Ver `.github/workflows/deploy.yml` para detalhes.
