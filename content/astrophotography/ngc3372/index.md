---
title: "NGC 3372 — Nebulosa de Carina"
date: 2026-04-23T19:28:08-03:00
draft: false
description: "Nebulosa de Carina capturada em banda estreita com filtro L-eXtreme a partir de Porto Alegre, RS. 150 minutos de integração revelando a estrutura em X característica e os filamentos de poeira ao redor de Eta Carinae."
tags: ["nebulosa", "banda estreita", "l-extreme", "carina", "eta carinae", "emissão", "hemisfério sul"]
categories: ["astrophotography"]
equipment:
  telescope: "ASKAR FRA400 (400mm f/5.6)"
  camera: "ZWO ASI533MC Pro (OSC refrigerada)"
  mount: "EQ-5 OnStep"
  filters: ["Optolong L-eXtreme"]
capture:
  date: "2025-01-10"
  location: "Porto Alegre, RS, Brasil"
  frames: 30
  exposure: "300s por frame"
  total_integration: "150 minutos"
  bortle: 7
cover:
  image: "ngc_3372_img.webp"
  alt: "Nebulosa de Carina (NGC 3372) em banda estreita H-alpha e OIII, mostrando a estrutura em X com Eta Carinae ao centro"
license: "CC BY-NC-ND 4.0"
license_url: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
---

## O Objeto

A Nebulosa de Carina (NGC 3372) é uma das regiões de formação estelar mais extensas e luminosas do céu austral, localizada a aproximadamente 7.500 anos-luz de distância na constelação de Carina. Com cerca de 300 anos-luz de extensão, ela supera em tamanho aparente a famosa Nebulosa de Órion, embora sua distância a torne menos óbvia a olho nu.

No coração da nebulosa reside Eta Carinae, uma das estrelas mais massivas e instáveis conhecidas — com massa estimada entre 100 e 150 massas solares. No século XIX, Eta Carinae passou por uma erupção gigantesca chamada de "Grande Erupção" (1837–1858), tornando-se temporariamente a segunda estrela mais brilhante do céu. Atualmente está envolta em uma nebulosa bipolar compacta chamada Homúnculo, expelida durante aquela erupção, e é considerada candidata a hipernova ou supernova em algum momento futuro — em escala astronômica.

A região em torno de NGC 3372 abriga também o aglomerado aberto Trumpler 14, um dos mais jovens e densos da Galáxia, com estrelas de apenas um a dois milhões de anos de idade. Os filamentos escuros visíveis na imagem são pilares de gás e poeira densa onde novos sistemas estelares estão em formação, esculpidos pelos ventos estelares intensos das estrelas massivas da região.

Por estar localizada a aproximadamente −60° de declinação, a Nebulosa de Carina é um objeto exclusivo do hemisfério sul — invisível para a grande maioria dos observatórios do hemisfério norte. Para observadores brasileiros, ela cruza o meridiano em alturas confortáveis durante o verão austral, oferecendo uma janela privilegiada para uma das regiões mais dinâmicas da Via Láctea.

---

## A Captura

Esta imagem foi capturada a partir de Porto Alegre, RS, em céu urbano com Bortle 7, utilizando o filtro Optolong L-eXtreme em modo banda estreita. O filtro transmite apenas as linhas de emissão H-alpha (656nm) e OIII (500nm), suprimindo efetivamente a poluição luminosa e permitindo capturar a estrutura nebular mesmo sob céu comprometido.

Foram integrados 30 frames de 300 segundos cada, totalizando 150 minutos de exposição. A câmera ZWO ASI533MC Pro operou refrigerada para minimizar o ruído térmico, e o guiamento foi realizado via ASIAIR Plus com câmera guia ZWO ASI120.

---

## O Processamento

**Stacking — Siril 1.4.0-beta2**

Os 30 frames foram calibrados e integrados no Siril com método de rejeição Winsorized Sigma Clipping (low=3.0, high=3.0), combinação aditiva com scaling e normalização habilitada. A rejeição por canal ficou entre 0,3% e 0,7%, indicando um conjunto de frames homogêneo.

**Pós-stacking — Siril**

A extração de gradiente foi realizada com GraXpert 3.0.2 (Umbriel) via interface externa, usando o algoritmo de IA com subtração e smoothing 0,5 — valor conservador para preservar a nebulosidade extensa de Carina. A calibração fotométrica (PCC) foi omitida intencionalmente, pois o filtro L-eXtreme em banda estreita torna essa etapa inadequada.

O stretch foi feito com Generalised Hyperbolic Stretch (GHS) com os parâmetros SP=0,22, D=3,8, b=5,0 e HP=0,98 em passada única, colocando o ponto de inflexão nas sombras médias — ideal para nebulosas de emissão com banda estreita. O denoising AI do GraXpert foi aplicado com strength 0,76 e aceleração GPU ativa. Por fim, foram aplicadas uma transformação de curvas em 5 pontos e remoção de ruído verde (SCNR) para eliminar o cast esverdeado residual.

**Finalização — Affinity Photo V2**

No Affinity, o ajuste de cor foi mantido deliberadamente minimalista para respeitar a natureza do dado em banda estreita. Foi aplicada uma única curva no canal azul (X=0,5 → Y=0,58) para introduzir o contraste H-alpha/OIII sem distorcer a paleta — com L-eXtreme, o H-alpha já domina tão fortemente o canal vermelho que qualquer ajuste mais agressivo no azul ou supressão do verde resulta em dominância magenta. Complementaram o processamento um ajuste de níveis com ponto de preto em 1% e incremento de saturação de +15% via HSL.

---

## Resultado

A estrutura em "X" característica de Carina está bem revelada, com os quatro braços de nebulosidade se abrindo a partir de Eta Carinae. Os filamentos escuros de poeira — pilares de formação estelar — aparecem com bom contraste contra a emissão H-alpha ao redor. Uma sessão futura com 60 a 80 frames deverá revelar com mais profundidade as extensões externas da nebulosa e os detalhes nos pilares mais afastados do centro.