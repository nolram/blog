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
