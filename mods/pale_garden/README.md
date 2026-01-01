# Pale Garden & Creaking - Mod para Mineclonia/VoxeLibre

## Descrição

Este mod adiciona o **Pale Garden** (Jardim Pálido) e o **Creaking** (Rangedor) ao Mineclonia, inspirado na atualização "Garden Awakens" do Minecraft 1.21.4!

## Características

### 🌲 Bioma Pale Garden
- Novo bioma raro de floresta pálida
- Geração natural no mundo
- Blocos de musgo pálido
- Tapetes de musgo pálido

### 🪵 Pale Oak (Carvalho Pálido)
- Troncos de Pale Oak
- Madeira de Pale Oak
- Tábuas de Pale Oak
- Folhas de Pale Oak
- Mudas de Pale Oak (crescem em árvores)

### 👻 Creaking (Rangedor)
- Mob hostil que spawna à noite no Pale Garden
- **Comportamento especial**: Só se move quando você NÃO está olhando!
- Invulnerável a dano direto
- Só pode ser derrotado destruindo o Creaking Heart

### 💎 Creaking Heart (Coração Rangedor)
- Bloco especial que controla o Creaking
- Ativa à noite (brilha)
- Spawna Creakings próximos
- Destruir o Heart mata todos os Creakings conectados
- Pode ser craftado para testes

## Instalação

1. Copie a pasta `pale_garden` para:
   - **Windows**: `C:\Users\[seu_usuario]\AppData\Roaming\Minetest\mods\`
   - **Linux**: `~/.minetest/mods/`

2. No Minetest: Configurar → Mods → Ative "Pale Garden & Creaking"

3. **IMPORTANTE**: Crie um **NOVO MUNDO** para o bioma gerar!
   - Mundos antigos não terão o bioma (só em chunks novos)

## Como Encontrar o Pale Garden

O Pale Garden é um bioma **raro**. Para encontrá-lo:

1. Crie um novo mundo com o mod ativado
2. Explore bastante (pode demorar)
3. Procure por áreas com:
   - Árvores com madeira clara/pálida
   - Chão coberto de musgo pálido
   - Atmosfera mais escura

**Dica**: Use o comando `/teleport` com coordenadas aleatórias para explorar mais rápido (modo criativo).

## Como Funciona o Creaking

### Comportamento:
1. Spawna à noite no Pale Garden
2. **Congela quando você olha para ele**
3. Se move e ataca quando você NÃO está olhando
4. Invulnerável a espadas, arcos, etc.

### Como Derrotar:
1. Encontre o **Creaking Heart** próximo (bloco brilhante à noite)
2. Destrua o Creaking Heart
3. Todos os Creakings conectados morrerão instantaneamente

## Crafting

### Tábuas de Pale Oak:
```
[Tronco Pale Oak] → 4x Tábuas Pale Oak
```

### Texturas 

`pale_garden/textures/` :

**Blocos:**
- `pale_oak_log.png` - Lateral do tronco
- `pale_oak_log_top.png` - Topo do tronco
- `pale_oak_planks.png` - Tábuas
- `pale_oak_leaves.png` - Folhas
- `pale_oak_sapling.png` - Muda
- `pale_moss_block.png` - Musgo pálido
- `creaking_heart_top.png` - Topo do Heart
- `creaking_heart_side.png` - Lateral do Heart
- `creaking_heart_top_active.png` - Topo ativo (animado)
- `creaking_heart_side_active.png` - Lateral ativa
- `creaking_heart_particle.png` - Partícula

**Mob:**
- `creaking_texture.png` - Textura do Creaking
- `spawn_egg_creaking.png` - Ovo de spawn

**Onde conseguir texturas:**
- Extrair do Minecraft 1.21.4
- Criar suas próprias
- Usar texturas placeholder (blocos cinza/brancos)

## Limitações

Este é um mod **simplificado** comparado ao Minecraft original:

- ❌ Sem Eyeblossoms
- ❌ Modelo do Creaking usa placeholder (esqueleto)
- ❌ Comportamento do Creaking é básico


## Compatibilidade

✅ Mineclonia
✅ VoxeLibre (MineClone2)
⚠️ Requer Luanti/Minetest 5.7+

## Problemas Conhecidos

- Creaking pode atravessar blocos às vezes
- Bioma pode ser muito raro
- Texturas placeholder (você precisa adicionar)

## Melhorias Futuras

- [ ] Adicionar resina e mecânica de resina
- [ ] Adicionar Eyeblossoms
- [ ] Modelo 3D customizado para o Creaking
- [ ] Sons customizados
- [ ] Melhorar IA do Creaking

## Licença

MIT License - Livre para usar e modificar


**Divirta-se explorando o Pale Garden! 🌲👻**
