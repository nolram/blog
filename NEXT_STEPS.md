# Próximos passos

## GitHub e deploy (obrigatório para publicar)

- [ ] **Ativar GitHub Pages**: repositório → Settings → Pages → Source: **GitHub Actions**
- [ ] **Verificar primeiro deploy**: após o próximo push para `main`, confirmar que o workflow passa em Actions
- [ ] **Confirmar domínio customizado**: Pages → Custom domain → `blog.nolram.dev`

## Cloudflare DNS

- [ ] Adicionar registro CNAME:
  - Nome: `blog`
  - Destino: `nolram.github.io`
  - Proxy: ativado (laranja) — SSL = **Full**
- [ ] Aguardar propagação DNS (~5-15 min)
- [ ] Testar acesso em https://blog.nolram.dev

## Personalização visual (alta prioridade)

- [ ] **Foto de perfil**: colocar imagem em `assets/img/author.jpg` e referenciar em `config/_default/languages.pt-br.toml` com `image = "img/author.jpg"`
- [ ] **Favicon**: colocar `favicon.ico` (e variantes PNG) em `static/`
- [ ] **Cor do tema**: testar outros color schemes do Blowfish em `config/_default/params.toml` — opções: `ocean`, `fire`, `forest`, `slate`, `terminal`, `blowfish`, `avocado`, `congo`, `princess`, `noir`, `autumn`, `custom`
- [ ] **Links sociais**: adicionar GitHub, Instagram ou outros em `config/_default/languages.pt-br.toml` na seção `[params.Author].links`

## Conteúdo (quando quiser publicar)

- [ ] **Primeiro post real de astrofotografia**: criar em `content/astrophotography/nome/index.md` com imagem processada
- [ ] **Primeiro post real de projeto**: ex. documentar o homelab
- [ ] **Remover posts de exemplo** ou transformá-los em posts reais (remover `draft: true`)
- [ ] **Página About**: criar `content/about/index.md` e adicionar ao menu em `config/_default/menus.pt-br.toml`

## Melhorias de blog (médio prazo)

- [ ] **Open Graph / SEO**: adicionar `images` no frontmatter dos posts para preview em redes sociais
- [ ] **Série de posts**: usar `series` no frontmatter para agrupar posts relacionados
- [ ] **Comentários**: Blowfish suporta Giscus (GitHub Discussions) — ver docs em blowfish.page/docs/partials/#comments
- [ ] **Analytics**: Blowfish suporta Umami, Plausible, Google Analytics — configurar em `params.toml`
- [ ] **Busca**: habilitar busca Fuse.js adicionando `"JSON"` ao output de `[outputs]` (já está configurado)

## Hugo Modules (manutenção)

Quando quiser atualizar o Blowfish para a versão mais nova:
```bash
hugo mod get github.com/nunocoracao/blowfish/v2@latest
hugo mod tidy
```

Verificar se o site ainda compila antes de fazer push.
