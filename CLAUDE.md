# nolram blog — guia para LLMs

Blog pessoal em Hugo com tema Blowfish. Deploy automático via GitHub Actions
para GitHub Pages em blog.nolram.dev.

## Stack

- **Hugo** 0.160.1+ Extended (obrigatório — versão standard não compila o tema)
- **Tema** Blowfish v2 instalado como Hugo Module (não submodule)
- **Deploy** GitHub Actions → GitHub Pages
- **Domínio** blog.nolram.dev via Cloudflare

## Sobre o autor

Marlon Baptista Quadros — DevOps engineer, mora no sul do Brasil (Rio Grande do Sul).
Trabalha com infraestrutura, Kubernetes, GitOps e IA local. Nas noites limpas
fotografa o céu profundo com telescópio.

Tom do blog: direto, técnico quando necessário, sem ser formal. Primeira pessoa.
Português brasileiro. Não usar termos como "entusiasta", "apaixonado por" ou
clichês de bio de LinkedIn.

## Equipamento de astrofotografia (usar estes dados em posts)

Telescópio: ASKAR FRA400 (refrator apocromático, portátil, compatível com redutor 0.7x) /
            Newtoniano 150mm f/5 (750mm focal, uso planetário e deep sky intermediário)

Câmera: ZWO ASI533MC Pro (deep sky, resfriada) /
        ZWO ASI662MC (planetária, alta taxa de frames) /
        ZWO ASI120MC (guia) /
        GoPro Hero 12 Black (timelapse)

Montagem: EQ-5 motorizada com OnStep, controlada via ASIAIR Plus
          (tracking, autoguiding, plate solving, dithering)

Filtros: Optolong L-Pro / Optolong L-eXtreme (Hα + OIII) /
         CLS / UHC / IR-UV Cut / Filtro Lunar

Localização habitual de captura: Rio Grande do Sul (Porto Alegre como base urbana,
                                  com deslocamentos para locais escuros como Cambará do Sul)

## Seções de conteúdo

| Seção | Slug | Uso |
|---|---|---|
| Astrofotografia | `/astrophotography` | Imagens astronômicas com metadados de captura |
| Projetos | `/projects` | Projetos técnicos, homelab, desenvolvimento |
| Misc | `/misc` | Livros, viagens, pensamentos gerais |

## Como criar um novo post

```bash
# Astrofotografia
hugo new astrophotography/nome-do-objeto/index.md

# Projeto técnico
hugo new projects/nome-do-projeto/index.md

# Misc
hugo new misc/nome-do-post/index.md
```

## Estrutura de um post (Page Bundle)

Sempre use Page Bundle — pasta com `index.md` e imagens juntas:

```
content/astrophotography/
  ngc7000-nebula-america/
    index.md
    ngc7000.jpg          ← cover.image
    ngc7000-crop.jpg     ← imagens no corpo
```

Referência de imagem no corpo: `![Legenda](ngc7000-crop.jpg)` (caminho relativo).

## Frontmatter por seção

### astrophotography
```yaml
---
title: "NGC 7000 — Nebulosa América do Norte"
date: 2026-04-10T22:00:00-03:00
draft: false
description: "Resumo de uma linha"
tags: ["nebulosa", "cygnus"]
categories: ["astrophotography"]
equipment:
  telescope: ""
  camera: ""
  mount: ""
  filters: []
capture:
  date: ""
  location: "Arroio do Sal, RS"   # default — mudar se for outra localização
  frames: 0
  exposure: ""
  total_integration: ""
  bortle: 4                        # default local — ajustar se diferente
cover:
  image: ""
  alt: ""
---
```

### projects
```yaml
---
title: ""
date: 2026-04-05T10:00:00-03:00
draft: false
description: ""
tags: []
categories: ["projects"]
tech_stack: []
github: ""
status: "completed"   # completed | in-progress | abandoned
cover:
  image: ""
  alt: ""
---
```

### misc
```yaml
---
title: ""
date: 2026-01-03T09:00:00-03:00
draft: false
description: ""
tags: []
categories: ["misc"]
---
```

## Convenções de escrita

- Idioma: português brasileiro
- Tom: direto, técnico quando o tema pede, sem ser formal
- Posts de astrofotografia: descrever o objeto, o processo de captura e
  o que torna a imagem interessante. Não exagerar no lirismo.
- Posts de projetos: explicar o problema antes da solução. Incluir
  blocos de código relevantes. Documentar o que *não* funcionou se
  for útil para o leitor.
- Títulos: sem clickbait, sem "Descubra como...", sem exclamação
- Não usar: "entusiasta", "apaixonado", "jornada", "ecossistema"

## Publicar um post

1. Abrir `index.md` do post
2. Mudar `draft: true` para `draft: false`
3. Confirmar que `date` está correto

```bash
git add content/
git commit -m "post: título do post"
git push
```

Deploy automático em ~2 min.

## SEO

### Regras obrigatórias para cada post

- **Imagem de capa**: nomear o arquivo como `cover.webp` (ou `cover.jpg`) dentro da pasta do
  post. O Blowfish detecta o padrão `*cover*` automaticamente para gerar `og:image` e
  `twitter:image`. Um nome arbitrário como `ic434_v1.webp` não gera os metadados sociais.
- **`description`**: sempre preencher, entre 70 e 160 caracteres. É o texto exibido no
  resultado de busca do Google e no preview de links.
- **`cover.alt`**: sempre preencher com descrição real da imagem — afeta acessibilidade e
  indexação no Google Images.
- **Alts de imagens inline**: usar descrições específicas, não genéricas
  (`"IC 434 Nebulosa Cabeça de Cavalo em narrowband Hα+OIII"`, não `"versão 1"`).
- **`title`**: sem truncamento — o Google exibe até ~60 caracteres no resultado.

### Estrutura SEO já configurada

- `og:image` e `twitter:card = "summary_large_image"` — automáticos quando a capa se chama
  `cover.*`
- `BreadcrumbList` JSON-LD — ativo via `enableStructuredBreadcrumbs = true` em `params.toml`
- `BlogPosting` JSON-LD com imagem e `author.sameAs` — via
  `layouts/partials/extend-head-uncached.html`
- Sitemap em `/sitemap.xml`, submetido ao Google Search Console (verificação via DNS no
  Cloudflare)
- `robots.txt` gerado automaticamente com `enableRobotsTXT = true`

### Pendências conhecidas

- `defaultSocialImage`: criar `assets/img/social-default.jpg` (1200×630px) e adicionar
  `defaultSocialImage = "img/social-default.jpg"` em `params.toml` para que páginas de
  listagem e a homepage tenham `og:image`
- Ícones PWA: `android-chrome-192x192.png` e `android-chrome-512x512.png` não existem em
  `/static/` — gerar via realfavicongenerator.net

## Repositório público — segurança

**Este repositório é público.** Tudo que for commitado fica visível para qualquer pessoa.

O que é seguro commitar:
- Token de verificação do Google Search Console (`verification.google`) — é público por design,
  só prova ownership do domínio
- Chaves públicas de analytics sem privilégios (ex: measurement ID do GA4)

O que **nunca** deve ser commitado:
- Tokens OAuth, service account JSON, API keys com permissões de escrita
- Senhas, secrets de CI/CD (usar GitHub Secrets no repositório)
- Arquivos `.env` com credenciais
- Tokens de acesso pessoal (PAT) do GitHub ou qualquer outro serviço

## O que NÃO fazer

- Não criar arquivos em `/static/` para imagens de posts — usar Page Bundle
- Não editar arquivos em `/public/` — gerados automaticamente, ignorados pelo git
- Não instalar o tema como submodule — já está como Hugo Module em `hugo.toml`
- Não alterar `deploy.yml` sem testar localmente antes
- Não usar `hugo new` sem especificar a seção correta (archetype errado)
- Não commitar credenciais, tokens de API ou secrets — repositório é público

## Rodar localmente

```bash
hugo server -D    # com drafts, live reload em localhost:1313
hugo server       # sem drafts (simula produção)
```

## Configuração do tema

- `hugo.toml` — configuração base
- `config/_default/params.toml` — visual do Blowfish
- `config/_default/languages.pt-br.toml` — autor, bio, links sociais
- `config/_default/menus.pt-br.toml` — menu de navegação

## Imagem de perfil

```
assets/img/author.jpg
```

Em `languages.pt-br.toml`:
```toml
[params.Author]
  image = "img/author.jpg"
```

## Deploy e CI/CD

- Push para `main` → GitHub Actions → `hugo --minify` → GitHub Pages
- URL: https://blog.nolram.dev
- Ver `.github/workflows/deploy.yml` para detalhes

---