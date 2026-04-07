# GAME DESIGN DOCUMENT
> Documento vivo — atualizar conforme o jogo evolui

---

## VISÃO GERAL

**Gênero:** Action RPG isométrico hack and slash  
**Plataforma alvo:** PC (Steam)  
**Engine:** Godot 4  
**Referência principal:** Path of Exile  
**Foco:** Loot, grinding e builds loucas sem restrição de classe  

**Conceito central:**
A classe define o ponto de partida, não o destino. Qualquer personagem pode se tornar qualquer coisa através da árvore de talentos e dos itens equipados.

---

## UNIVERSO

**Tom:** Fantasia sombria, mundo amaldiçoado e corrompido  
**Personagens:** Anti-heróis moralmente ambíguos — não são escolhidos pelo bem, são pessoas que abraçaram o que os outros rejeitaram e sobreviveram por isso  

**Narrativa central:**
Um Deus (nome indefinido) criou um mundo que considera perfeito — povoado por criaturas lendárias que causam caos. O jogador não é um herói enviado para salvar esse mundo. É um invasor. Atravessa a criação do Deus, mata ele, e então o mundo dele se torna um playground de grinding infinito.

---

## ATRIBUTOS

| Atributo | Cor | Conceito | Mecânica |
|----------|-----|----------|----------|
| **Fúria** | 🔴 Vermelho | Poder visceral, brutalidade | Dano físico, resistência, vigor |
| **Instinto** | 🟢 Verde | Reflexo, precisão, sobrevivência | Velocidade, crítico, esquiva |
| **Arcano** | 🟣 Roxo | Domínio sobre forças além do natural | Poder de magias, mana, potência de itens raros |

**Regra de builds híbridas:**
Itens têm requisitos de atributos. Qualquer classe pode usar qualquer item se investir nos atributos certos na árvore de talentos. A restrição é natural — um Brutamontes com pouco Arcano conjura magias fracas.

---

## CLASSES

### ⚔️ Brutamontes
- **Atributo base:** Fúria
- **Recurso:** Sangue — gasta vida para usar skills. Quanto mais perto da morte, mais perigoso
- **Identidade:** Guerreiro que corrompeu o próprio corpo para ser mais letal
- **Ponto inicial na árvore:** Canto Fúria

### 🏹 Arqueiro
- **Atributo base:** Instinto
- **Recurso:** Fôlego — regenera com movimento. Parado perde eficiência, em movimento é letal
- **Identidade:** Sem lar, sem lei, sem misericórdia
- **Ponto inicial na árvore:** Canto Instinto

### 🔮 Mago
- **Atributo base:** Arcano
- **Recurso:** Mana — clássico, nome pode mudar com o universo
- **Identidade:** Usa magia que foi banida por uma razão
- **Ponto inicial na árvore:** Canto Arcano

---

## ÁRVORE DE TALENTOS

**Formato:** Triângulo compartilhado entre todas as classes  
- Cada classe começa num canto do triângulo
- O centro é a zona híbrida — só acessível vindo de 2 cantos diferentes
- É aqui que as builds loucas acontecem

**Estrutura por canto (3 camadas):**
- Camada 1 — Identidade (3 nós): básico da classe
- Camada 2 — Especialização (6 nós): define o estilo de jogo
- Camada 3 — Limiar (3 nós): poderes fortes, custam muitos pontos

**Zona Híbrida (centro):**
- 6 nós especiais
- Só acessíveis investindo em 2 atributos diferentes
- Total inicial: ~30 nós

---

## SISTEMA DE DANO

### Tipos de Dano

| Tipo | Categoria | Descrição |
|------|-----------|-----------|
| **Dano Direto** | Instantâneo | Dano aplicado de uma vez no impacto — base de ataques físicos e mágicos |
| **Damage Over Time (DOT)** | Contínuo | Dano aplicado em ticks ao longo do tempo — não pode matar instantaneamente, mas acumula pressão |

### Damage Over Time (DOT)

Dano aplicado em intervalos regulares após uma condição ser ativada (status, habilidade, item).

**Regras gerais:**
- DOT **não pode matar** de tick único — deixa o alvo em 1 HP se o tick mataria (a definir)
- DOT é **stackável** — múltiplas aplicações acumulam e o dano soma
- Cada aplicação tem duração própria; nova aplicação **refresha** o timer
- Cap de stacks por fonte de DOT: **10 stacks** (padrão, pode variar por skill/item)

**Os 4 efeitos de status do jogo:**

| Status | Ícone | Atributo | Categoria | Implementado | Mecânica |
|--------|-------|----------|-----------|:---:|---------|
| **Fogo** | 🔥 | Arcano / Instinto | DOT | ✅ | Queimadura stackável — 1 × stacks por tick, 3 ticks/seg, cap 10, duração 3s |
| **Sangramento** | 🩸 | Fúria | DOT | ❌ | A definir |
| **Veneno** | 🟢 | Instinto | DOT | ❌ | A definir |
| **Congelamento** | 🧊 | Arcano | DOT / Controle | ❌ | A definir |
| **Sombrio** | 🌑 | Arcano | DOT / Debuff | ❌ | A definir |
| **Corrupção** | 🟣 | Arcano | DOT / Debuff | ❌ | A definir |

---

## SKILLS

- **Abertas para qualquer classe** — sem restrição de runa ou gem
- A restrição é natural via atributos: skill de magia num Brutamontes com pouco Arcano é fraca
- Sistema a ser detalhado futuramente

**Tensão de build híbrida:**
Um Brutamontes que usa skills de Mago precisa de Mana — que ele não tem naturalmente. Resolve via itens que convertem Sangue em Mana, ou Lendários que fazem skills de magia custarem Sangue.

---

## SISTEMA DE LOOT

### Raridades

| Raridade | Ícone | Drop | Característica |
|----------|-------|------|----------------|
| Comum | ⬜ | Frequente | Base do jogo, sem afixos especiais |
| Mágico | 🔵 | Moderado | 1-2 afixos interessantes |
| Raro | 🟡 | Baixo | 3-4 afixos poderosos |
| Lendário | 🟠 | Rarísssimo | Efeito único que muda mecânicas |

### Lendários — Habilitadores de Build
Lendários não são só mais fortes — eles **quebram regras** e habilitam builds que não seriam possíveis de outra forma.

**Exemplos de efeitos:**
- *"Cada ponto de Fúria aumenta o dano de magias em 2%"* → habilita Brutamontes mago
- *"Ataques à distância aplicam stack de Arcano no inimigo"* → habilita Arqueiro conjurador
- *"Quanto mais perto do inimigo, maior o dano de magias"* → habilita Mago corpo a corpo
- *"Ao matar um inimigo, recupera vida com base no Instinto"* → habilita builds de sustain híbrido

### Afixos
> A ser detalhado futuramente

---

## LOOP DE JOGO

```
Grinda dungeons
    ↓
Dropa lendário com efeito único
    ↓
Descobre uma build nova que isso habilita
    ↓
Vai pra árvore de talentos realocar pontos
    ↓
Grinda dungeons mais difíceis
```

---

## CAMPANHA — 3 MAPAS INICIAIS

### 🪦 Mapa 1 — A Passagem

**Tema:** Mortos vivos, ruínas, névoa densa  
**Conceito narrativo:** Centenas de aventureiros tentaram passar antes. Todos fracassaram. Os corpos ainda estão lá — alguns viraram zumbis, alguns ainda carregam seus equipamentos. O jogador saqueia os fracassados que vieram antes.  
**Mensagem:** *Esse mundo não te recebe. Você vai ter que se impor.*  
**Mecânica ensinada:** Gerenciamento de recursos (Sangue, Fôlego e Mana são limitados)  
**Tom:** Pesado, lento, sufocante  

**Inimigos:**
- Zumbis de aventureiros
- Esqueletos com armaduras quebradas
- Necromante menor que anima os corpos

**Boss: O Último Comandante**
- General que liderou o maior grupo que tentou passar. Morreu aqui. Foi corrompido.
- Agora comanda os mortos como se ainda estivesse em batalha — dando ordens, formando fileiras, usando táticas militares
- Ele não sabe que está morto
- **Mecânica:** Invoca zumbis em formação, forçando o jogador a pensar em posicionamento

---

### 🌋 Mapa 2 — A Ascensão

**Tema:** Vulcão ativo, pontes de pedra sobre lava, fortalezas de obsidiana  
**Conceito narrativo:** Não são mortos acidentais. São criaturas que escolheram esse lugar — seres que pertencem ao caos. Elite da criação do Deus.  
**Mensagem:** *Você é pequeno aqui.*  
**Mecânica ensinada:** Posicionamento e mobilidade — o terreno mata tanto quanto os inimigos  
**Tom:** Opressivo, grandioso, perigoso  

**Inimigos elite:**
- **Colossos de Cinza** — gigantes de pedra vulcânica, lentos mas devastadores, resistentes a dano físico
- **Guardiões da Chama** — guerreiros com armadura derretida fundida na pele, rápidos e agressivos
- **Invocadores do Magma** — controlam o terreno, criam poças de lava, forçam mobilidade constante
- **Sentinelas** — patrulham em grupo, alertam outros inimigos

**Boss: A Rainha Fundida**
- Figura que um dia foi humana. Buscou poder no coração do vulcão e se fundiu com ele
- Metade carne, metade magma. Não é um monstro — é alguém que foi longe demais em busca de poder
- Espelho do que o jogador pode se tornar
- **Mecânica:** Transforma o campo de batalha durante a luta — abre fissuras, drena lava, força reposicionamento constante

---

### ✨ Mapa 3 — O Paraíso (nome indefinido)

**Tema:** Arquitetura impossível e flutuante, dourada mas perturbadora, simetria perfeita demais  
**Conceito narrativo:** A criação do Deus em sua forma mais pura. Criaturas magníficas que atacam sem hesitar. O jogador é o intruso.  
**Mensagem:** *Você não deveria estar aqui.*  
**Mecânica ensinada:** Tudo junto — o jogo assume que o jogador já sabe jogar  
**Tom:** Grandioso e perturbador  

**Inimigos:**
- Anjos distorcidos
- Guardiões divinos
- Seres criados para ser belos e são letais

**Boss Final: O Arquiteto (nome indefinido)**
- O Deus que criou esse mundo. Acredita que fez algo perfeito.
- Não entende raiva, medo ou dor — nunca precisou
- Quando o jogador chega, ele não entra em fúria. Fica **curioso**. Tenta converter, absorver, transformar o jogador numa de suas criações.

**Fases da luta:**
1. **Fase 1 — Curiosidade:** Testa o jogador. Ataques calculados, quase didáticos
2. **Fase 2 — Confusão:** Percebe que o jogador não pode ser convertido. Fica genuinamente confuso. Ataques erráticos — ele nunca falhou antes
3. **Fase 3 — Desconstrução:** Sua forma perfeita se fragmenta. Ele não sabe como perder

**Morte:** Sem cutscene dramática. Ele simplesmente para. O mundo continua existindo sem criador — cheio de criaturas lendárias. Seu para explorar.

---

## PÓS-CAMPANHA — GRINDING INFINITO

- Sistema de dungeons com níveis infinitos
- Cada nível mais difícil, mais inimigos, itens melhores
- Design de grinding intencional — ex: farmar dungeon nível 40 centenas de vezes para conseguir aquele item mítico que permite avançar
- O mundo do Arquiteto é o playground

---

## PERSPECTIVA E CONTROLES

- **Câmera:** Isométrica fixa (estilo PoE/Diablo)
- **Movimento:** A definir (clique ou WASD)
- **Combate:** Tempo real, hordas de inimigos

---

## STACK TÉCNICA

- **Engine:** Godot 4
- **Linguagem:** GDScript
- **Editor:** VS Code + extensão Godot Tools
- **Plataforma alvo:** Windows (Steam)

---

## PENDÊNCIAS E DECISÕES FUTURAS

- [ ] Nome do jogo
- [ ] Nome das raridades de loot (fugir de Comum/Raro/Lendário)
- [ ] Nome do Mapa 3
- [ ] Nome do Boss final (O Arquiteto é placeholder)
- [ ] Sistema de skills detalhado
- [ ] Afixos dos itens por raridade
- [ ] Árvore de talentos detalhada (nós específicos)
- [ ] Sistema de movimento (clique vs WASD)
- [ ] Progressão de atributos (quanto por nível/item)
- [ ] Sistema de inventário
- [ ] Sistema de save
- [ ] Multiplayer? (não discutido)
