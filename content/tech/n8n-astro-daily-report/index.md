---
title: "N8n Astro Daily Report"
date: 2026-04-19T21:37:50-03:00
draft: false
description: "Como automatizei o planejamento das minhas sessões de astrofotografia com n8n, Telescopius, OpenWeather e um modelo de scoring personalizado para meu equipamento."
tags: ["astrofotografia", "automação", "n8n", "homelab", "astronomia"]
categories: ["tech"]
cover:
  image: "cover.png"
  alt: "Diagrama do workflow n8n para planejamento automático de sessões de astrofotografia"
---

Quem pratica astrofotografia sabe que boa parte do trabalho acontece **antes** de ligar o telescópio. Decidir o que fotografar exige considerar fase da lua, previsão do tempo, altitude dos objetos no horizonte, limitações do equipamento e o tempo disponível na noite. Por muito tempo fiz isso manualmente, consultando apps separados e anotando em papel. Resolvi automatizar.

O resultado é um workflow no **n8n** que roda todo dia às 16h e me envia pelo **Telegram** um relatório completo com os melhores objetos para observar naquela noite — com filtros sugeridos, tempo recomendado por alvo e previsão meteorológica dividida por período.

---

## A ideia central

O objetivo não era apenas listar objetos visíveis. Qualquer app de astronomia faz isso. A ideia era um ranking que respondesse uma pergunta mais específica: **dado o meu equipamento, o meu céu e as condições desta noite, o que vale mais a pena fotografar?**

Para isso o workflow combina três fontes de dados e aplica um modelo de scoring próprio.

---

## Fontes de dados

### Telescopius API

O [Telescopius](https://telescopius.com) é uma plataforma voltada para astrofotografia que, entre outras coisas, expõe uma API REST para patronos. Ela fornece a lista de "highlights" — objetos deep sky recomendados para uma dada localização, com metadados como magnitude, tamanho angular, tipo e coordenadas RA/Dec.

O endpoint principal utilizado é o de highlights, que já aplica filtros básicos de altitude mínima e distância da lua. Os dados retornados incluem o suficiente para calcular posição no céu hora a hora ao longo da noite.

### OpenWeather OneCall API

A previsão hora a hora da [OpenWeather](https://openweathermap.org/api/one-call-3) fornece cobertura de nuvens, umidade, vento, probabilidade de chuva e visibilidade para cada hora da noite. Esses dados alimentam tanto a análise de condições por período (início, meio e madrugada) quanto o próprio score de cada objeto.

### Cálculo astronômico local

Para saber a altitude de cada objeto em cada hora da noite, o workflow calcula diretamente via JavaScript, sem depender de API externa. O fluxo implementa:

- **GMST** (Greenwich Mean Sidereal Time) a partir do timestamp Unix
- **LST** (Local Sidereal Time) ajustado para a longitude local
- **Altitude** via fórmula de astronomia esférica usando a RA/Dec do objeto e a latitude do observador

Isso permite calcular, para cada hora entre o pôr e o nascer do sol, a altitude de qualquer objeto — e cruzar esse dado com as condições meteorológicas daquela mesma hora.

---

## O modelo de scoring

Aqui está o coração do sistema. Cada objeto recebe um score composto por quatro fatores:

### 1. Score de condições × altitude

Para cada hora da janela noturna em que o objeto está acima da altitude mínima configurada (35°), calcula-se:

```
score_hora = scoreCond(nuvens, umidade, vento) × (altitude - alt_min) / (90 - alt_min)
```

O score final de condições é a média de todas as horas válidas. Isso favorece objetos que ficam altos **nas melhores horas da noite**, não apenas em algum momento.

### 2. Compatibilidade de FOV

O sensor da câmera (quadrado, 9×9mm) tem um campo de visão que varia conforme o instrumento e o uso de redutor. O workflow calcula o FOV em arcminutos e pontua cada objeto pela proporção entre seu tamanho angular e o FOV disponível:

| Proporção objeto/FOV | Score |
|---|---|
| < 5% | 0.20 — muito pequeno, sem detalhe |
| 15–60% | 1.00 — ideal |
| > 100% | 0.20 — requer mosaico |

Um aglomerado globular de 15′ fotografado com o refrator no modo padrão ocupa cerca de 11% do FOV — score razoável. O mesmo objeto com o Newtoniano de focal maior ocupa mais campo e sobe no ranking.

### 3. Penalidade de lua por tipo de objeto

A lua afeta objetos de formas muito diferentes. Uma nebulosa de emissão fotografada com filtro L-eXtreme (que isola Ha e OIII) sofre pouco mesmo com lua intensa. Uma galáxia de baixo brilho superficial com lua de 80% é praticamente inviável em céu urbano.

```
penalidade_lua(emissão + L-eXtreme, lua 70%) = 5%
penalidade_lua(galáxia LSB, lua 70%)          = 65%
```

### 4. Penalidade de brilho superficial

Para galáxias e objetos difusos, o brilho superficial estimado (mag/arcsec²) é cruzado com o limite prático do céu urbano. Objetos muito difusos são penalizados ou filtrados.

---

## Filtro e instrumento sugeridos

Com base no tipo do objeto e na fase da lua, o sistema sugere automaticamente:

- **Filtro**: usando o inventário real disponível — L-eXtreme, L-Pro, UHC, CLS
- **Instrumento**: refrator ou Newtoniano, considerando o tamanho angular do objeto

Por exemplo: nebulosas planetárias pequenas (<5′) vão automaticamente para o Newtoniano, que entrega maior escala de placa. Nebulosas de emissão grandes (>60′) vão para o refrator com redutor 0.7×.

---

## Alocação de tempo

O tempo disponível na sessão (configurável, padrão 240 minutos) é distribuído proporcionalmente ao score de cada objeto, respeitando um mínimo por alvo. O resultado aparece no relatório como uma tabela com sugestão de minutos por objeto.

---

## Arquitetura do workflow

O fluxo no n8n segue esta sequência:

```
Cron (16h) → Set Config
           → [OpenWeather + Telescopius] em paralelo
           → Merge
           → Merge & Score        ← cálculo principal
           → Fix links + horários locais
           → Prep Context
           → Render Base Bullets  ← formata cada alvo
           → Generate Tips        ← dicas determinísticas por tipo
           → Merge Tips + Bullets ← monta HTML para Telegram
           → Send Telegram        ← envia mensagens separadas por alvo
```

![Workflow n8n completo: do Cron ao envio no Telegram, passando pelas APIs do Telescopius e OpenWeather](n8n-astro-daily.png)

Um ponto de design relevante: as dicas por objeto são geradas deterministicamente em JavaScript, não por LLM. Uma versão anterior usava um modelo local via Ollama, mas a abordagem determinística é mais rápida, mais previsível e não tem ponto de falha extra.

---

## O relatório no Telegram

O relatório chega em mensagens separadas para não ultrapassar o limite de tamanho do Telegram:

1. **Cabeçalho**: janela noturna, fase da lua, FOV ativo
2. **Previsão noturna**: condições por período (início, meio, madrugada)
3. **Uma mensagem por alvo**: horário ideal (UTC e local), altitude, filtro, instrumento, tempo sugerido e link para o Telescopius
4. **Checklist + tabela de tempo**: itens operacionais e distribuição dos minutos da sessão

![Relatório de astrofotografia recebido no Telegram: previsão noturna por período e ficha completa do primeiro alvo (Omega Centauri)](telegram.png)

---

## Configurações por sessão

Toda a personalização fica em um único nó de configuração. Alterar o instrumento de `FRA400` para `NEWTONIAN` muda o FOV calculado, os scores, as sugestões de filtro e as dicas — sem tocar em nenhum outro nó.

Parâmetros principais:
- Localização (lat/lon)
- Instrumento ativo e uso de redutor
- Altitude mínima e tamanho mínimo de objeto
- Limiar de lua para priorizar narrowband
- Tempo total da sessão e mínimo por alvo

---

## Próximos passos

Algumas ideias que ainda estão no backlog:

- **Suporte a sessões portáteis**: mudar a localização para Cambará do Sul com um parâmetro e recalcular tudo para céu escuro
- **Histórico de sessões**: registrar o que foi fotografado para penalizar objetos já bem integrados
- **Alerta de seeing**: cruzar dados de [Astrospheric](https://www.astrospheric.com) ou similar para estimar o seeing previsto, não só transparência e vento
- **Notificação de janela**: além do relatório das 16h, um alerta quando a melhor janela da noite estiver começando

---

## Referências e recursos

- [Telescopius](https://telescopius.com) — plataforma de planejamento para astrofotografia
- [Telescopius API](https://api.telescopius.com) — documentação REST (acesso para patronos)
- [OpenWeather One Call API 3.0](https://openweathermap.org/api/one-call-3)
- [n8n](https://n8n.io) — plataforma de automação self-hosted
- [Siril](https://siril.org) — processamento de imagens astronômicas
- [GraXpert](https://www.graxpert.com) — extração de gradiente e denoising com IA