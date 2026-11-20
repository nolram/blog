---
title: "Qwen em GPUs de consumo: quantização, VRAM e tok/s"
date: 2026-11-20T12:00:00-03:00
draft: true
description: "Medi Qwen 3.8-27B numa RTX 5090 e o Flash-Next 125B numa RTX 4070 Ti de 12 GB com llama.cpp e Strata. Tokens/s, TTFT e o que cada escolha custou."
tags: ["llm", "qwen", "strata", "llama-cpp", "rag", "infra", "local"]
categories: ["tech"]
series: ["ia-local"]
series_order: 1
tech_stack: ["Qwen", "llama.cpp", "Strata", "K3s", "Open WebUI", "NVIDIA", "RTX 5090", "RTX 4070 Ti", "pgvector"]
github: "https://github.com/nolram/architecture-diagrams"
status: "in-progress"
cover:
  image: "cover.svg"
  alt: "Dois nós de cluster com GPUs de gerações diferentes servindo modelos Qwen: RTX 4070 Ti de 12 GB rodando um MoE de 125B via Strata e RTX 5090 de 32 GB rodando um denso de 27B via llama.cpp"
---

Às 21:04 UTC de 4 de novembro de 2026 o Kubernetes matou o pod do meu chat por falta de memória. Ele estava tentando resumir a própria conversa: o prompt tinha 151.064 tokens numa janela de 131.072, o servidor devolveu HTTP 400 com `This model's maximum context length is 131072 tokens. However, you requested 151064 tokens in the messages`, e o Open WebUI caiu no fallback de truncar o histórico bruto em 4.000 caracteres. Quatro minutos depois uma segunda compactação entrou por cima da primeira, e o pod morreu no limite de memória.

O número que me fez continuar com isso é outro. Contei o banco do Open WebUI nesta sessão, em 20 de novembro: 187 conversas criadas entre 7 de março e hoje, e 139 delas — 74,3% — têm pelo menos uma resposta de um modelo com Qwen no nome. Nenhuma dessas escolhas passou por mim comparando benchmark. Foi o que ficou disponível e funcionou.

Eu podia ter jogado a culpa no hardware. Em vez disso medi as coisas, e metade das explicações que eu tinha prontas não sobreviveu à própria medição. É disso que este post fala.

## Por que rodar isso em casa, se dá trabalho

A resposta curta: porque a alternativa não me deixava saber o que tinha acontecido.

Uma API hospedada com contexto de tamanho variável não te devolve o número de 151.064 tokens. Ela te entrega uma resposta visivelmente pior, você descobre dias depois por intuição, e não consegue apontar a causa. Aqui eu tenho o log, o contador, o tamanho exato do payload e a linha de código do fallback que cortou tudo em 4.000 caracteres. Foi assim que achei os bugs de configuração que estavam travando a plataforma inteira, e eles aparecem mais adiante.

O resto do texto é o preço dessa visibilidade, medido em duas placas de consumo.

## A topologia

Dois nós num cluster k3s, ambos `Ready`, v1.34.5, tudo no mesmo namespace de IA.

O **nó A** é o control-plane e carrega a parte pesada de dados: Ryzen 9 5900X (12 núcleos, 24 threads, Zen 3, **sem AVX-512**), 121 GiB de DDR4-3200 e uma RTX 4070 Ti de 12 GB. Nele rodam a interface de chat, o serviço de RAG, o endpoint de embeddings e — a parte que parece errada — o maior modelo da casa: um **Qwen3.8-Flash-Next de 125B parâmetros totais** (MoE, ~6B ativos por token, mais ~51B de embedding n-gram) servido pelo Strata.

O **nó B** tem a GPU grande e metade da RAM: Ryzen 9 9950X3D (16 núcleos, 32 threads, com AVX-512), 60 GiB de DDR5 e uma RTX 5090 de 32 GB. Nele rodam o **Qwen3.8-27B denso** servido pelo llama.cpp com 256k de contexto, e o reranker da busca.

Repare na inversão: o modelo de 125B está na placa de 12 GB, e o de 27B está na placa de 32 GB. Não é acidente nem teimosia — é consequência do tipo de esparsidade de cada um, e é a coisa que essa configuração me ensinou melhor. Falo dela na próxima seção.

Os dois motores falam OpenAI-compatible, então a interface enxerga um catálogo único e não sabe qual backend respondeu. A interface é auto-hospedada e os endpoints internos ficam na rede privada do cluster.

![Topologia: interface de chat auto-hospedada apontando para dois motores OpenAI-compatible — um MoE servido por Strata na GPU de 12 GB com arena de experts na RAM do nó A, e um denso servido por llama.cpp na GPU de 32 GB do nó B, com API hospedada como última camada](topologia-qwen.svg)

Não há YAML aqui de propósito: a stack roda num cluster pessoal, e a descrição da arquitetura é textual por opção. As ferramentas citadas são públicas e os nomes dos hosts ficaram de fora.

## Os números

Duas regras antes da tabela: todo número medido nesta sessão está marcado com a data, e todo número que **não** foi medido nesta sessão está datado no texto. Número sem data, aqui, é número velho.

**Setup da medição (20 de novembro de 2026):** 10 passes, `temperature: 0`, `seed: 42`, `max_tokens: 200`, streaming, contadores lidos do próprio servidor (`llamacpp:tokens_predicted_total`, `llamacpp:tokens_predicted_seconds_total`, `llamacpp:prompt_tokens_total`, `llamacpp:prompt_tokens_cached_total`, `llamacpp:prompt_seconds_total`) em vez de cronômetro de cliente.

| | Qwen3.8-27B (nó B) | Flash-Next 125B (nó A) |
|---|---|---|
| Motor | llama.cpp `server-cuda13-b12019` | Strata `0.2.13-cuda13` / engine `0.1.59 (cuda)` |
| GPU | RTX 5090 32 GB | RTX 4070 Ti 12 GB |
| Quantização | Q5_K_XL | UD-IQ3_XXS |
| Pesos no disco | — | 76,3 GB |
| **Decode** | **68,9 tok/s** | **42,8 tok/s** (mediana de 53 sessões, 12/nov) |
| **TTFT** (prompt de 4 tok) | **59 ms** (mediana de 10) | não medido nesta sessão |
| **Prefill** (25.320 tok frios) | **3.680 tok/s** → 6,9 s | não medido nesta sessão |
| **TTFT** (mesmo prompt quente) | **78 ms** | 100% dos tokens de prompt reusados |

Os detalhes que valem a leitura:

**O decode do 27B é 2.000 tokens em 29,01 s**, sem oscilação entre passes. Foi a medida mais limpa que já tirei nessa casa.

E quase ficou de fora deste post por erro de instrumento. A primeira versão do script de prefill pedia os contadores do servidor por um nome que não existe neste build — `llama:prompt_eval_seconds_total`, quando a métrica aqui se chama `llamacpp:prompt_seconds_total`. A regex não casava, a função devolvia zero e o relatório imprimia `0 t em 0.00 s` sem reclamar. Eu já tinha escrito **3.514 tok/s** no rascunho, e só bati o olho nessa conta ao auditar o post: esse número e os 93,5% não estavam em artefato nenhum. Re-medido com o nome certo, o frio dá **3.680 tok/s em 6,88 s para 25.320 tokens**, e o reuso quente é **100%**, não os 93,5% anotados. O hábito que ficou: o modo de falha silenciosa de uma regex em cima de `/metrics` é devolver zero, não devolver erro.

**"6B ativos" não significa 6 GB.** É o erro de leitura mais comum em MoE, e eu cometi ele. O servidor precisa de acesso a todos os experts, mais a tabela de n-gram de ~51B de parâmetros. A esparsidade reduz FLOPs, não memória. O que torna o 125B viável numa 4070 Ti é o Strata fazer paging: uma arena de experts em RAM — o discovery de 4 de novembro media **40,9 GiB** de arena, com **32.768** tokens de KV residentes em VRAM — e um cache quente dentro da placa. Aqui cabe uma correção minha: esse cache media 4,1 GiB no engine de novembro inicial, e no boot limpo de 12 de novembro, já no engine atual, ele aparece dimensionado em **3,17 GiB com 1.648 experts residentes**. É o mesmo mecanismo, medido duas vezes, com número diferente — e é exatamente por isso que cada medida deste post tem data. Os 76,3 GB de pesos nunca couberam inteiros em lugar nenhum — nem nos 121 GiB de RAM, onde, somados aos ~45 GiB que o host já usa, estouram a máquina e passam a viver de page cache no NVMe.

E é aqui que a inversão das GPUs faz sentido. O 125B é *memory-bound* de um jeito que RAM grande resolve: ele come 121 GiB de DDR4, e uma placa de 32 GB não teria o que fazer com ele. O 27B denso é *compute-bound*: cabe inteiro em VRAM e só rende com largura de banda de memória de vídeo, que é justamente onde a 5090 ganha. Em miúdos: **mais VRAM não te dá o modelo grande; mais RAM te dá.**

**Contexto cheio cobra pedágio, e o tamanho da janela não é preferência estética.** A própria referência oficial do formato para o IQ3_XXS numa RTX 5070 de 12 GB cai de ~62 tok/s em contexto curto para ~49 tok/s em 128k — 20% antes de qualquer erro meu entrar na conta.

## O trade-off que eu escolhi sem querer

Aqui está a parte da qual eu mais gostei, e o contrário do que eu imaginava quando escrevi o primeiro rascunho.

Em 4 de novembro, o discovery do Strata com o empacotamento **ISTA** media **75–119 tok/s** de decode nessa mesma 4070 Ti. Na nota de comparação de 7 de novembro, que roda os dois pacotes lado a lado, o ISTA fica em **86–113 tok/s** com o cache de experts acertando **97,8%** dos requests, contra **36–48 tok/s** e **45–51%** de acerto com o **Unsloth V3.1** — a mediana de 42,8 que está na tabela acima cai exatamente dentro dessa faixa.

A queda não é do motor nem do pacote. É aritmética de VRAM: a placa tem 12 GB, o pod de embedding reserva 1.750 MiB, sobram **~4,5 GiB** para o cache de experts — e é esse espaço que determina quantos experts ficam quentes na GPU. O pacote novo tem uma geometria de experts que cabe pior nesse espaço. A evidência não veio de uma placa minha: no relatório upstream que acompanha essa investigação, **uma 3090 de 24 GB rodando o MESMO motor e o MESMO pacote marca ~96 tok/s**. O limitador é VRAM, não o motor — e é por isso que esse número entrou aqui com a ressalva certa: não foi na minha máquina.

E o motivo pelo qual eu estou em 42 tok/s mesmo sabendo disso é um trade-off aceito, não uma derrota: o pacote novo corta **41% dos tokens de resposta** e **46% dos tokens de raciocínio** para a mesma tarefa. Menos custo, menos pressão de KV e de VRAM, em troca de um decode ~2,5× mais lento. Numa conversa interativa isso é ruim; num agente que processa milhares de chamadas, o custo por token útil manda mais.

Levei esse datapoint para o projeto do motor em 7 de novembro ([issue #5328](https://github.com/Niko1221/Strata/issues/5328)). A issue foi fechada em 10 de novembro como resolvida no engine atual — o reteste que fechou foi numa 4080 SUPER, mesma família de arquitetura da minha placa, só que com 16 GB em vez de 12. Eu rodo hoje exatamente esse engine (0.2.13 / 0.1.59) e continuo em 42,8 tok/s de mediana numa placa que tem 4 GiB a menos de cache de experts. A correção é real; ela só não alcança quem está no degrau de VRAM abaixo do do reteste.

Uma última correção de narrativa: durante a investigação registrei `GPU 99% no decode`. Eu li "stall"; é **compute-saturated**. A placa está ocupada, e um barramento lento não explicaria esse número.

## O que eu esperava e o que apareceu

Eu achava que o gargalo seria velocidade de geração. Ele apareceu como latência de entrada.

Os primeiros tokens do 27B saem em 59 ms para prompts de 4 tokens. Quando o prompt tem 25.320 tokens, o teto do tempo até o primeiro token é o prefill: **7,2 segundos** de TTFT, medidos na mesma sessão, na mesma placa, com o mesmo motor.

E aqui vem a parte que se inverteu nesta semana. Durante meses eu culpei a busca: uma pergunta com contexto recuperado do RAG levava ~17,6 segundos de ponta a ponta, e eu tinha medido que o gargalo era o reranker rodando em CPU. **Hoje isso não vale mais** — o reranker passou para GPU e a mesma régua de 36 casos deu **p50 de 18,31 s → 0,20 s** no mesmo índice (o baseline antigo, com outro chunker, media 17,59 s), com recall preservado. Sobrou o que restava: 6,88 s de prefill no modelo, contra uma busca de 0,2 s. **O gargalo passou a ser, com folga, o processamento do prompt no próprio modelo.**

Conclusão contra-intuitiva: local não é "latência baixa" por natureza. Com cache de conversa, um turno de sessão longa custa 78 ms; sem cache, o mesmo prompt leva 7,242 s até o primeiro token — 93× de diferença para a mesma pergunta. A latência local não é uma propriedade da placa, é uma propriedade do seu cache.

## A API oficial como última camada

A stack tem a API oficial do Qwen configurada na interface, ao lado dos dois endpoints locais. Não é enfeite: na contagem que rodei hoje, `qwen/qwen3.8-27b` — a versão hospedada — produziu 41 respostas em 9 conversas. É o terceiro jeito de instanciar o mesmo modelo base nesta casa: Q5_K_XL em VRAM própria, IQ3_XXS em arena de RAM, e a variante hospedada num servidor de terceiros, cuja quantização eu não vejo de fora.

O critério de escolha é mecânico, não estético: se a tarefa precisa de mais contexto do que a janela local comporta, ou de uma janela de raciocínio que eu não sustento em tempo útil no hardware que tenho, ela sai de casa. Não vou comparar qualidade entre os três aqui, porque não tenho número que sustente a comparação, e opinião sobre qualidade de modelo não é dado.

## O que não funcionou

**A compaction que compactava nada.** É o bug mais caro da lista, e eu o tinha como comportamento normal. A quebra de 4 de novembro não foi falta de memória: foi a compressão de contexto tentando resumir uma conversa que já não cabia na janela do modelo que faria o resumo. No cutover de novembro a janela do chat primário encolheu de 256k para 131k, e o resumidor passou a ser o próprio modelo da sessão, num slot único. O prompt isolado de resumo levou junto os ~150k tokens da conversa, estourou a própria janela, as duas chamadas do resumidor voltaram vazias, e o código caiu no fallback mecânico — truncamento de string do histórico bruto em 4.000 caracteres, que é exatamente o `summary_chars=4000` que apareceu no log. Sessão acima da janela do modelo é **incompactável pelo modelo da própria sessão**: a compactação só é viável enquanto o total fica abaixo da janela. Isso é decisão de arquitetura, não bug — e eu descobri que tinha uma dela escondida.

O conserto veio em 4 e 5 de novembro: teto global de compressão baixado de 200.000 para 131.000 tokens, limite de resposta explícito no card do modelo, gatilho de compactação por modelo em vez de um cap único, e corte por tokens em vez de por número de mensagens — no chat que eu usei de cobaia, um corte por mensagens tinha reduzido 177.825 tokens para meros 163.000. A validação: um agente que estava em 86k de prompt e compactando a cada turno (20 a 56 s por turno) passou para 26,5k, zero compactações, 5 s por turno.

Um bug irmão, esse ainda mais simples: nada limitava o retorno de ferramenta. Uma busca textual em `/home/user` devolveu 3,67 MB de resultado e levou um pedido a ~1,1M de tokens, contra janelas de 131k e 256k. O teto ficou em 40.000 caracteres, e o motivo de ser caracteres e não tokens é que eu tinha estimado 4 caracteres por token e a medição com o tokenizer real deu 2,96 — então o teto em caracteres não depende de nenhuma estimativa de token.

**A medição que apodreceu em uma semana.** Em 4 de novembro o Strata reportava `gpu_pcie_gen: 1`. Eu escrevi a conclusão: a placa estava negociando em Gen1 x16, ~1 GB/s de largura de banda, e era por isso que o decode não saía de 40. Parecia o achado da investigação — explicava eu estar abaixo do número de referência do fabricante em hardware comparável.

Em 11 de novembro medi o mesmo slot dentro do pod: **Gen4, x16, exatamente como deve ser**. O gargalo nunca foi o barramento: era o cache de experts, cuja taxa de acerto varia entre 40% e 53%, e o decode acompanha essa taxa.

O detalhe que me faz contar essa história é que a correção estava na minha própria nota de 4 de novembro: o link negociava em Gen1 **no idle**, por ASPM, o que é o comportamento esperado de uma placa ociosa. Eu tinha o número certo e li a condição errada — uma leitura de estado de repouso virou diagnóstico de gargalo. Uma medição que eu aceitei por uma semana sem tentar refutar estava errada; o que salvou a investigação não foi ter medido, foi ter medido de novo depois de mudar uma variável.

## Os diagramas

A figura de topologia deste post é gerada por [uma ferramenta própria](https://github.com/nolram/architecture-diagrams), que é pública e aberta — é a parte desta história que dá para inspecionar. Ela recebe um spec estruturado e devolve SVG e PNG do mesmo renderizador, com layout automático e legenda de categorias gerada sozinha. A stack em si continua privada.

## O que medi do RAG

Um parágrafo, porque o resto merece post próprio. O corpus é 417 documentos em 3.632 chunks, medidos com uma régua de 36 casos. A troca de reranker para GPU hoje deu p50 de 18,31 s → 0,20 s **sem mexer em recall** (0,6222 nas duas passadas, CPU e GPU, no mesmo índice) — o que era esperado, já que trocar o backend do reranker muda o hardware, não o conjunto de documentos pontuado. O que mexeu no recall foi outra coisa, o chunker, e isso fica para o próximo. Método de medição, armadilhas de harness e por que a régua foi construída antes da otimização ficam num post próprio — e a base onde tudo isso roda é o cluster de dois nós que descrevi lá em cima.

## Quando cada opção faz sentido

**Fica local quando a tarefa é de contexto controlado.** Um 27B denso numa 5090 entrega 68,9 tok/s com 256k de janela — rápido o bastante para iteração de agente, que é onde o tempo composto importa. Um MoE de 125B numa 4070 Ti com 121 GiB de RAM entrega 42 tok/s e uma janela de 128k. Os dois funcionam porque cada um cabe no tipo de gargalo da máquina onde está.

**Não compensa quando o gargalo é o prefill.** Se seu fluxo joga dezenas de milhares de tokens por turno e você não tem cache de conversa, a placa é irrelevante: você paga 7 segundos em cada turno, e uma API hospedada com prefix caching agressivo ganha esse duelo por construção.

**Não compensa quando você não vai medir.** Esta é a que eu queria ter lido antes de começar. O preço de rodar isso em casa não é a conta de luz, é a obrigação de sustentar cada número que você escreve. Levei uma semana para descobrir que a explicação de que eu mais gostava estava errada — e essa explicação era a única justificativa que eu tinha para o decode parado em 42 tok/s. Se você não vai re-medir, qualquer número que você escrever — inclusive os meus — é opinião formatada como dado.

## O próximo passo

O que falta nesta stack não é potência. É decidir, com uma régua de qualidade em vez de intuição, se vale a pena voltar para o empacotamento que entrega até 113 tok/s e aceita os tokens a mais — e um harness de avaliação que me deixe comparar duas configurações em vez de votar numa. Os dois são assunto dos próximos posts.

Existe também uma alavanca aberta, registrada em 11 de novembro: uma flag opt-in do motor que, nos números reportados pelo próprio projeto, levou o acerto do cache de **54–61% para 71–78%**, com **+10,2% de decode**, sob condições específicas (uma GPU, execução serial, sem batching). Ela ataca exatamente o número que manda no meu resultado, e ainda não a testei — então ela está aqui como hipótese medida por outra pessoa, não como resultado meu.
