---
title: "NGC 5139 — Omega Centauri"
date: 2026-04-19T21:17:51-03:00
draft: false
description: "O maior e mais massivo aglomerado globular da Via Láctea, capturado do céu urbano de Porto Alegre com 147 frames e processado integralmente no Siril 1.4."
tags: ["aglomerado globular", "ngc5139", "omega centauri", "siril", "asi533mc", "deep sky", "L-Pro"]
categories: ["astrophotography"]
equipment:
  telescope: "ASKAR FRA400 (refrator apocromático)"
  camera: "ZWO ASI533MC Pro (OSC, refrigerada)"
  mount: "EQ-5 com OnStep"
  filters: ["Optolong L-Pro"]
capture:
  date: "2026-04-19"
  location: "Porto Alegre, RS, Brasil"
  frames: 147
  exposure: ""
  total_integration: ""
  bortle: 7
cover:
  image: "cover.webp"
  alt: "NGC 5139 — Omega Centauri, aglomerado globular em Centaurus"
license: "CC BY-NC-ND 4.0"
license_url: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
---

![NGC 5139 — Omega Centauri, aglomerado globular em Centaurus](cover.webp)

## O objeto

O NGC 5139, conhecido como Omega Centauri, não é um aglomerado globular comum. É o maior e mais massivo da Via Láctea — com cerca de 10 milhões de estrelas comprimidas em uma esfera de aproximadamente 150 anos-luz de diâmetro, a uma distância de cerca de 17.000 anos-luz da Terra. Sua escala é tão absurda que astrônomos suspeitam que ele seja na verdade o núcleo remanescente de uma galáxia anã que foi absorvida pela Via Láctea há bilhões de anos.

Para quem observa do hemisfério sul, Omega Centauri é um objeto espetacular mesmo a olho nu — aparece como uma "estrela borrada" de magnitude 3.9 na constelação de Centaurus. No telescópio, é simplesmente inigualável.

## A captura

A sessão foi realizada na madrugada de 19 de abril de 2026, do quintal em Porto Alegre — céu Bortle 7, com poluição luminosa urbana moderada e o canal vermelho bem contaminado, como é típico da cidade. O objeto estava em excelente posição para o hemisfério sul, cruzando o meridiano por volta da meia-noite local.

O setup utilizado foi o refrator apocromático ASKAR FRA400, uma lente compacta e portátil que entrega boa qualidade óptica para deep sky. A câmera foi a ZWO ASI533MC Pro refrigerada, com filtro Optolong L-Pro para mitigar parcialmente a poluição luminosa sem recorrer à banda estreita — o que não faria sentido para um aglomerado globular, que não tem emissão nebular significativa.

A montagem EQ-5 com OnStep garantiu o tracking, e o ASIAIR Plus centralizou o controle de câmera, plate solving e guiding. Foram integrados **147 frames** em 32 bits com rejeição Winsorized Sigma Clipping (low=3.0, high=3.0), resultando em uma rejeição por canal extremamente equilibrada — entre 0.3% e 0.6% — indicativo de uma sessão limpa sem artefatos significativos.

A câmera refrigerada dispensou a necessidade de darks, simplificando o fluxo de calibração.

## O processamento

Todo o pós-processamento foi feito no **Siril 1.4.0-beta2**, com ferramentas externas integradas via interface. O fluxo seguiu esta ordem:

**Background Extraction (GraXpert 3.0.2)**
Antes de qualquer stretch, o gradiente de fundo foi removido com o GraXpert em modo AI, smoothing 0.5 e correção por subtração. O Siril 1.4.x deprecou a interface C interna do GraXpert — é necessário instalar o executável externo e apontá-lo em File → Preferences → Miscellaneous.

**Photometric Color Calibration**
Com o Catálogo Gaia DR3, o PCC calibrou o balanço de branco usando 1.582 estrelas de referência. Os fatores resultantes foram K0=1.000 (vermelho), K1=0.552 (verde), K2=0.477 (azul) — desvio esperado para Porto Alegre com filtro L-Pro, onde o canal vermelho domina. O algoritmo corrigiu automaticamente.

**Generalised Hyperbolic Stretch**
O stretch foi o passo mais crítico. O NGC 5139 tem um núcleo extremamente brilhante e um halo externo com estrelas muito mais dimers — o desafio é equilibrar os dois sem estourar o centro nem perder o halo.

A configuração que funcionou: D=4.153, b=3.640, SP=0.13365, HP=0.98000 — uma única passada com escala logarítmica ativa. O segredo está no SP baixo (~0.13): ele posiciona o ponto de inflexão da curva nas sombras, puxando o halo sem comprimir as altas luzes. SP alto (>0.40), como testado inicialmente, comprime o núcleo e desperdiça o halo.

**Denoising (GraXpert AI)**
Com 147 frames integrados o ruído já era baixo. O denoising com strength 0.62 foi suficiente para limpar o fundo sem suavizar as estrelas do halo externo. Rodando na CPU, levou cerca de 15 minutos — com GPU o tempo cai para 1-2 minutos.

**Curves Transformation**
Sete pontos em spline cúbica, escala logarítmica, sem clipagem em nenhum canal. Os pontos foram ajustados para escurecer o fundo mantendo a textura, realçar as estrelas de meias-luzes e proteger o núcleo.

**Color Saturation e SCNR**
Duas passadas leves de saturação (0.35 e 0.20, background factor 0.50) para revelar as cores reais das estrelas sem exagerar. O SCNR em seguida removeu o cast esverdeado residual típico da poluição luminosa de Porto Alegre.

**Finalização no Affinity V2**
O TIFF foi exportado em 16-bit e finalizado no Affinity V2 (Pixel Estúdio) com ajustes de curvas por canal para neutralização final do cast de cor e um toque de contraste.

## Resultado

O campo de visão do ASKAR FRA400 captura o NGC 5139 inteiro com espaço generoso ao redor. A resolução estelar do halo externo está bem preservada, com estrelas individuais separadas até as bordas do cluster. O núcleo ficou brilhante e limpo sem saturação visível. O campo de fundo é riquíssimo — a proximidade ao plano galáctico de Centaurus enche o frame de estrelas com cores variadas, e há ao menos duas galáxias de fundo visíveis nos cantos da imagem.

Para uma sessão em céu Bortle 7, o resultado ficou acima do esperado. Com mais integração — 200+ frames — e eventualmente uma noite em Cambará do Sul, o halo externo mais difuso do cluster poderia ser revelado com ainda mais profundidade.

---

*Processado com Siril 1.4.0-beta2, GraXpert 3.0.2 (Umbriel) e Affinity V2.*