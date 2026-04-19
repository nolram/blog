#!/usr/bin/env bash
# Reprocessa imagens já commitadas no git: converte PNG/JPG/JPEG para WebP,
# embute metadados de copyright e atualiza referências nos index.md.
# Executar uma única vez para normalizar o histórico de imagens existentes.

set -euo pipefail

QUALITY=85
AUTHOR="Marlon Baptista Quadros"
COPYRIGHT="© $(date +%Y) Marlon Baptista Quadros. CC BY-NC-ND 4.0 — https://creativecommons.org/licenses/by-nc-nd/4.0/"

if ! command -v convert &>/dev/null; then
  echo "Erro: imagemagick não encontrado. Instale com: sudo apt install imagemagick" >&2
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

mapfile -t images < <(git ls-files content/ | grep -Ei '\.(png|jpg|jpeg)$')

if [[ ${#images[@]} -eq 0 ]]; then
  echo "Nenhuma imagem PNG/JPG/JPEG encontrada nos arquivos rastreados."
  exit 0
fi

echo "Encontradas ${#images[@]} imagens para reprocessar."
echo ""

converted=()
skipped=()

for file in "${images[@]}"; do
  [[ -f "$file" ]] || continue

  webp_file="${file%.*}.webp"
  original_name="$(basename "$file")"
  webp_name="$(basename "$webp_file")"
  size_kb=$(du -k "$file" | cut -f1)

  echo "🔄  $file (${size_kb}KB)"

  if convert "$file" \
      -quality $QUALITY \
      -set copyright "$COPYRIGHT" \
      -set Author "$AUTHOR" \
      "$webp_file"; then

    webp_kb=$(du -k "$webp_file" | cut -f1)
    echo "   ✓  ${size_kb}KB → ${webp_kb}KB"

    # Atualiza referências nos index.md da mesma pasta
    dir="$(dirname "$file")"
    index="$dir/index.md"
    if [[ -f "$index" ]]; then
      if grep -q "$original_name" "$index"; then
        sed -i "s|$original_name|$webp_name|g" "$index"
        echo "   ✎  Referência atualizada em $index"
      fi
    fi

    git add "$webp_file"
    git rm "$file"

    converted+=("$file → $webp_file")
  else
    echo "   ⚠  Falha na conversão — mantendo original." >&2
    skipped+=("$file")
  fi

  echo ""
done

echo "========================================"
echo "Concluído."
echo "  Convertidas : ${#converted[@]}"
echo "  Com falha   : ${#skipped[@]}"
echo ""

if (( ${#converted[@]} > 0 )); then
  echo "Alterações prontas para commit. Revise com 'git diff --cached' e depois:"
  echo ""
  echo "  git commit -m \"chore: converter imagens existentes para WebP com copyright\""
fi
