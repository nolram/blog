---
title: "IC 2944 — Lambda Centauri Nebula"
date: 2026-04-21T00:03:16-03:00
draft: false
description: "Primeira imagem em banda estreita do IC 2944, a Lambda Centauri Nebula, capturada com filtro L-eXtreme a partir de Porto Alegre. 72 frames integrados revelando as regiões HII e estruturas de emissão ao redor do aglomerado Lambda Centauri."
tags: ["nebulosa", "emissão", "banda estreita", "l-extreme", "centaurus", "deep sky", "HOO"]
categories: ["astrophotography"]
equipment:
  telescope: "ASKAR FRA400"
  camera: "ZWO ASI533MC Pro (refrigerada, OSC)"
  mount: "EQ-5 com OnStep"
  filters: ["Optolong L-eXtreme"]
capture:
  date: "2026-04-20"
  location: "Porto Alegre, RS, Brasil"
  frames: 72
  exposure: ""
  total_integration: ""
  bortle: 7
cover:
  image: "cover.webp"
  alt: "IC 2944 — Lambda Centauri Nebula em banda estreita HOO"
license: "CC BY-NC-ND 4.0"
license_url: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
---

## IC 2944 — Lambda Centauri Nebula

![IC 2944 — Lambda Centauri Nebula em banda estreita HOO](ic2944_final.webp)

O IC 2944, também conhecido como **Lambda Centauri Nebula** ou **Running Chicken Nebula**, é uma nebulosa de emissão localizada na constelação de Centaurus, a aproximadamente 6.000 anos-luz de distância. A região abriga um jovem aglomerado estelar aberto — Lambda Centauri — cujas estrelas massivas ionizam o hidrogênio ao redor, criando as estruturas avermelhadas características de regiões HII.

Um dos objetos mais fascinantes associados ao IC 2944 são os **Thackeray's Globules** — pequenas nuvens de gás e poeira opacas visíveis contra o brilho da nebulosa, consideradas possíveis berçários estelares em estágio inicial de colapso gravitacional.

---

## Captura

Esta foi minha primeira imagem do IC 2944 com o filtro **Optolong L-eXtreme**, que passa seletivamente as bandas de H-alpha (656nm) e OIII (500nm), bloqueando grande parte da poluição luminosa urbana. Porto Alegre é uma cidade com alto nível de poluição luminosa — o L-eXtreme é uma ferramenta essencial para extrair nebulosas de emissão nessas condições.

A sessão totalizou **72 frames** capturados pelo ASIAIR Plus, com guiagem ativa pela ZWO ASI120 e dithering habilitado para reduzir padrões de ruído fixo. O stacking foi realizado no **Siril 1.4.0-beta2** com método **Winsorized Sigma Clipping** (low=3.0, high=3.0), resultando em rejeição equilibrada de 0.12% a 0.68% por canal.

---

## Processamento

O fluxo de processamento seguiu o pipeline padrão para imagens OSC em banda estreita:

### No Siril 1.4.0-beta2

**1. Background Extraction (GraXpert 3.0.2 — Umbriel)**
Extração de gradiente com algoritmo AI, smoothing 0.5, aceleração GPU ativa via DmlExecutionProvider. O L-eXtreme tende a introduzir gradientes sutis mesmo em campos sem dominância de poluição luminosa — a extração foi suave para preservar a emissão difusa da nebulosa.

**2. Calibração de cor — PULADA**
Com filtro de banda estreita, a calibração fotométrica (PCC) não é aplicável — o filtro bias artificialmente os canais de cor ao passar apenas H-alpha e OIII. Esta etapa é reservada para imagens com filtro broadband (L-Pro).

**3. Stretch — Generalised Hyperbolic Stretch (GHS)**
Parâmetros utilizados:
- D: 3.80 / b: 5.0 / SP: 0.22 / HP: 0.98
- Colour model: Even weighted luminance

O SP em 0.22 foi escolhido para nebulosas difusas — mais alto que o valor usado em aglomerados globulares (~0.13), colocando a inflexão do stretch nas meias-luzes e puxando as estruturas tênues do halo sem saturar o núcleo.

**4. Denoising (GraXpert AI)**
Strength: 0.70 — levemente mais agressivo que o usual para compensar o ruído intrínseco das imagens em banda estreita. Tempo de execução: ~1 min 46s com GPU.

**5. Curves Transformation**
S-curve suave em 6 pontos no canal RGB mestre para aumentar contraste e profundidade sem introduzir clipping (Clip: 0.000%).

**6. SCNR — Remoção de ruído verde**
Algoritmo Average neutral, preserving lightness. O L-eXtreme tende a deixar um cast esverdeado residual — o SCNR remove esse artefato de forma eficiente.

**7. Color Saturation**
Uma passada com Amount: 0.25 e Background factor: 0.50, concentrando a saturação nas estrelas e nebulosa sem contaminar o fundo.

**8. Correção de cast quente**
Curva leve no canal RGB mestre (X=0.15, Y=0.13) para neutralizar o cast avermelhado residual do fundo — descobri nesta sessão que a correção no canal RGB mestre é mais segura que no canal Red isolado, que tende a criar contornos avermelhados ao redor das bordas da nebulosa.

### No Affinity V2 (Pixel Estúdio)

- **Curvas:** stretch visual para compensar a linearidade do TIFF exportado
- **Níveis:** entrada de preto em 1% — suficiente para escurecer o fundo sem clipar estrelas fracas
- **HSL:** saturação global +15% para revelar a riqueza de cores do campo estelar

---

## O que está na imagem

O campo de visão do ASKAR FRA400 com a ASI533MC Pro captura uma região generosa de Centaurus, revelando:

- **IC 2944** — a nebulosa principal, com sua estrutura em bolha bem definida e variações internas de densidade
- **IC 2948** — nebulosa adjacente, integrada visualmente à região central
- **Duas regiões HII secundárias** no canto inferior do campo — estruturas de emissão menores que fazem parte do mesmo complexo nebular
- **Campo estelar denso** característico da proximidade ao plano galáctico

---

## Aprendizados desta sessão

**L-eXtreme vs L-Pro — diferenças de abordagem:**
Trabalhar em banda estreita exige ajustes específicos em cada etapa do processamento. O PCC é inválido, o SP do GHS deve ser mais alto, e o b deve ser mais agressivo para puxar estruturas difusas. A saturação final deve ser mais conservadora, pois o H-alpha já é naturalmente intenso.

**Correção de cast em banda estreita:**
A tentação é corrigir o cast quente do fundo no canal Red isolado — mas isso cria um contorno avermelhado indesejado ao redor das bordas da nebulosa. A correção no canal RGB mestre, com um ponto suave nas sombras, é mais segura e produz resultado mais natural.

**Multi-sessão stacking:**
Esta imagem será futuramente integrada com mais 30 frames capturados em sessão anterior com os mesmos equipamentos. O Siril suporta multi-sessão stacking — basta calibrar cada noite separadamente e juntar os lights calibrados antes do stacking final. Com mais integração, as estruturas difusas do halo e os Thackeray's Globules devem aparecer com mais detalhe.

---

## Próximos passos

- Integrar os 30 frames adicionais para aumentar SNR e revelar estruturas mais tênues
- Revisitar o objeto a partir de Cambará do Sul (Bortle ~4) para comparar a diferença de céu escuro
- Tentar paleta SHO no Affinity para explorar a separação H-alpha / OIII

---

*Processado com Siril 1.4.0-beta2, GraXpert 3.0.2 (Umbriel), StarNet v2 e Affinity V2.*