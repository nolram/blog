---
title: "NGC 5128 — Centaurus A"
date: 2026-04-19T21:00:37-03:00
draft: false
description: "Centaurus A registrada do céu urbano de Porto Alegre com 59 frames — faixa de poeira, núcleo AGN e campo estelar rico em uma das galáxias mais fascinantes do céu austral."
tags: ["ngc5128", "centaurus a", "galáxia", "deep sky", "asi533mc", "siril", "l-pro", "hemisfério sul"]
categories: ["astrophotography"]
equipment:
  telescope: "ASKAR FRA400"
  camera: "ZWO ASI533MC Pro (refrigerada)"
  mount: "EQ-5 com OnStep"
  filters: ["Optolong L-Pro"]
capture:
  date: "2026-04-19"
  location: "Porto Alegre, RS, Brasil"
  frames: 59
  exposure: ""
  total_integration: ""
  bortle: 7
cover:
  image: "cover.webp"
  alt: "NGC 5128 — Centaurus A, galáxia elíptica com faixa de poeira característica, capturada de Porto Alegre"
license: "CC BY-NC-ND 4.0"
license_url: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
---

## NGC 5128 — Centaurus A
![NGC 5128 — Centaurus A, galáxia elíptica com faixa de poeira](ngc5128.webp)

Centaurus A é, sem dúvida, uma das galáxias mais fascinantes do céu austral. Localizada a aproximadamente 13 milhões de anos-luz de distância na constelação de Centaurus, ela carrega uma característica única que a torna imediatamente reconhecível: uma faixa de poeira escura que corta seu núcleo elíptico ao meio — vestígio de uma colisão galáctica ocorrida há milhões de anos.

Além da estrutura visual marcante, NGC 5128 abriga um dos núcleos galácticos ativos (AGN) mais próximos da Terra, com um buraco negro supermassivo de dezenas de milhões de massas solares acelerando jatos de matéria a velocidades relativísticas. Um objeto que une beleza visual e física extrema em um único alvo.

---

## Condições de captura

Esta imagem foi obtida do céu urbano de Porto Alegre, em condições de Bortle 7, com o filtro Optolong L-Pro para reduzir a poluição luminosa. Foram integrados 59 frames em 32-bit com Winsorized Sigma Clipping, resultando em uma rejeição de apenas 0.2–0.6% por canal — stack equilibrado e limpo apesar do número menor de frames.

A câmera ZWO ASI533MC Pro refrigerada garantiu baixo ruído térmico mesmo sem uso de darks, e a montagem EQ-5 com OnStep proporcionou tracking estável durante toda a sessão.

---

## Processamento

Todo o fluxo de pós-stacking foi realizado no **Siril 1.4.0-beta2**, seguido de finalização no **Affinity V2**.

### No Siril

**Background Extraction** com GraXpert 3.0.2 (algoritmo AI, smoothing 0.7) removeu os gradientes de poluição luminosa antes de qualquer ajuste de cor. Em seguida, a **Photometric Color Calibration** usando o catálogo Gaia DR3 calibrou as cores com base em 1061 estrelas de referência — os fatores resultantes (K0=1.000, K1=0.543, K2=0.472) revelaram a dominância do canal vermelho característica do céu de Porto Alegre com filtro L-Pro.

O **stretch** foi feito com o GHS (Generalised Hyperbolic Stretch) em uma única passada: D=3.680, b=4.500, SP=0.18 e HP=0.97. Para galáxias com núcleo AGN brilhante, um SP levemente mais alto que o usado em aglomerados globulares evita saturar o centro enquanto ainda revela a estrutura difusa ao redor. O **denoising** com GraXpert AI (strength 0.77, GPU ativa) concluiu em apenas 1 minuto e 24 segundos, limpando o fundo sem comprometer as estrelas do campo.

O StarNet foi executado para gerar a starmask, mas o starless resultante não foi utilizado como base — o núcleo AGN extremamente brilhante de Cen A gera halos residuais no processo de remoção de estrelas, tornando o arquivo starless inadequado para este objeto. O processamento seguiu diretamente no arquivo com estrelas.

### No Affinity V2

A finalização incluiu uma S-curve suave no canal RGB mestre para dar profundidade, um ajuste leve no canal azul (meias-luzes +0.02) para neutralizar o cast quente residual do L-Pro, saturação de +15% no HSL para revelar as cores reais das estrelas sem exagero, e um ajuste de níveis de 3% no input preto para escurecer o fundo.

---

## Resultado

A faixa de poeira de Cen A ficou claramente definida cruzando o núcleo elíptico. O halo da galáxia apresenta gradação suave com o tom dourado/amarelado característico de galáxias elípticas ricas em estrelas velhas. O campo estelar é extraordinariamente rico — resultado da proximidade de Cen A com o plano galáctico — com estrelas exibindo cores naturais que vão do laranja das gigantes vermelhas ao branco azulado das estrelas mais jovens.

Com apenas 59 frames de céu urbano, o halo externo difuso de Cen A ainda não está plenamente revelado. Ele se estende muito além dos limites visíveis nesta imagem e exige mais integração — e idealmente um céu mais escuro — para aparecer em toda sua extensão.

---

## Próximos passos

A meta para uma próxima sessão de Centaurus A é alcançar 150+ frames, preferencialmente de Cambará do Sul, onde o céu escuro vai permitir revelar as extensões do halo difuso. O filtro L-Pro continua sendo a escolha certa para este objeto — galáxias elípticas não emitem em H-alpha ou OIII, então o L-eXtreme não traria ganho real aqui.

---

*Processado com Siril 1.4.0-beta2 + GraXpert 3.0.2 + Affinity V2*
