# nolram — blog pessoal

Blog pessoal em Hugo com o tema [Blowfish](https://blowfish.page), hospedado em [blog.nolram.dev](https://blog.nolram.dev).

## Primeira vez

Instale Hugo Extended e Go, depois baixe as dependências do tema:

```bash
hugo mod tidy
```

## Rodar localmente

```bash
hugo server -D
```

O site fica disponível em `http://localhost:1313`. O flag `-D` inclui posts com `draft: true`.

## Criar novo post

### Astrofotografia

```bash
hugo new astrophotography/nome-do-objeto/index.md
```

O archetype `astrophotography` já inclui todos os campos de metadados de captura. Imagens do post ficam na mesma pasta (`content/astrophotography/nome-do-objeto/`).

### Projeto

```bash
hugo new projects/nome-do-projeto/index.md
```

### Misc

```bash
hugo new misc/nome-do-post/index.md
```

## Publicar um post

1. Abra o arquivo do post e remova `draft: true` (ou altere para `draft: false`)
2. Faça commit e push para `main`:
   ```bash
   git add .
   git commit -m "post: título do post"
   git push
   ```
3. O GitHub Actions faz o build e deploy automaticamente.

## Organização de imagens (Page Bundles)

Use sempre Page Bundles: crie uma **pasta** com o slug do post e coloque o `index.md` junto das imagens:

```
content/
  astrophotography/
    ngc7000-nebula-america/
      index.md          ← conteúdo do post
      ngc7000.jpg       ← imagem principal (referenciada no frontmatter como cover.image)
      ngc7000-crop.jpg  ← imagens adicionais usadas no corpo do post
```

Para referenciar imagens dentro do post, use o caminho relativo:

```markdown
![Legenda da imagem](ngc7000-crop.jpg)
```

## Compressão automática de imagens

Um pre-commit hook converte automaticamente imagens PNG/JPG maiores que **2MB** para **WebP** antes do commit, usando `imagemagick`.

**Requisito:** `imagemagick` instalado localmente.

```bash
# Ubuntu/Debian
sudo apt install imagemagick

# macOS
brew install imagemagick
```

Se o `imagemagick` não estiver instalado, o hook emite um aviso e **não bloqueia** o commit.

O arquivo original é removido e substituído pelo `.webp`. Se o `index.md` do post referenciar a imagem pelo nome original, atualize o caminho após a conversão:

```markdown
<!-- antes -->
![NGC 7000](ngc7000.png)

<!-- depois -->
![NGC 7000](ngc7000.webp)
```

> O hook vive em `.git/hooks/pre-commit` e não é versionado pelo git. Em uma nova clonagem,
> copie o arquivo de referência do repositório e torne-o executável:
> ```bash
> chmod +x .git/hooks/pre-commit
> ```

## SEO

### Checklist por post

- [ ] Imagem de capa nomeada `cover.webp` (ou `cover.jpg`) na pasta do post — necessário para
      gerar `og:image` e preview de links no WhatsApp, LinkedIn e Twitter/X
- [ ] `description` preenchida no frontmatter (70–160 caracteres)
- [ ] `cover.alt` com descrição real da imagem
- [ ] Alts de imagens inline descritivos (não "versão 1", "foto 2", etc.)
- [ ] `title` com até ~60 caracteres para não ser truncado no Google

### O que já está configurado

| Recurso | Estado |
|---|---|
| `og:image` / `twitter:image` | Automático — requer `cover.*` no page bundle |
| `twitter:card = "summary_large_image"` | Ativo |
| BreadcrumbList JSON-LD | Ativo (`enableStructuredBreadcrumbs = true`) |
| BlogPosting JSON-LD com imagem e autor | Via `layouts/partials/extend-head-uncached.html` |
| Sitemap | `/sitemap.xml` — submetido ao Google Search Console |
| robots.txt | Gerado automaticamente pelo Hugo |
| Verificação Google Search Console | Via DNS (Cloudflare) |

### Pendências

- Criar `assets/img/social-default.jpg` (1200×630px) e adicionar
  `defaultSocialImage = "img/social-default.jpg"` em `config/_default/params.toml` para que
  a homepage e páginas de listagem também tenham `og:image`
- Gerar ícones PWA (`android-chrome-192x192.png`, `android-chrome-512x512.png`) via
  [realfavicongenerator.net](https://realfavicongenerator.net) e colocar em `/static/`

## Segurança — repositório público

**Este repositório é público.** Todo commit fica visível permanentemente.

**Pode commitar com segurança:**
- Token de verificação do Google Search Console — público por design
- Measurement IDs de analytics (ex: `G-XXXXXXXXXX` do GA4)

**Nunca commitar:**
- Tokens OAuth, service account JSON, API keys com permissões de escrita
- Senhas e secrets de CI/CD → usar [GitHub Secrets](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions)
- Arquivos `.env` com credenciais
- Tokens de acesso pessoal (PAT) do GitHub ou qualquer outro serviço

## Licença

As imagens astronômicas publicadas neste blog estão sob
[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) —
compartilhamento permitido com atribuição, sem uso comercial e sem modificações.

Os textos e código estão sob [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

Veja a [página de licença](https://blog.nolram.dev/license) para detalhes completos.

## Estrutura do repositório

```
blog/
├── .github/workflows/deploy.yml   # CI/CD para GitHub Pages
├── archetypes/                    # Templates de frontmatter por seção
├── config/_default/               # Configurações do Blowfish (params, menus, idioma)
├── content/
│   ├── astrophotography/          # Posts de astrofotografia
│   ├── projects/                  # Posts de projetos técnicos
│   └── misc/                      # Posts variados
├── static/
│   └── CNAME                      # Domínio customizado
├── go.mod                         # Hugo Module (tema Blowfish)
└── hugo.toml                      # Configuração principal do Hugo
```
