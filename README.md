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
