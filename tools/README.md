# Exportador de catálogo BetterCraft

O script `export_catalog.py` varre estaticamente todos os arquivos `.lua` de `games/bettercraft`, encontra chamadas `core.register_node`, `core.register_craftitem` e `core.register_tool`, e registra os campos úteis para o site.

Ele também busca recursivamente todos os arquivos dentro de diretórios chamados `textures/` e `models/`, relacionando texturas e modelos aos itens quando os nomes são encontrados.

## Gerar o JSON consumido pelo site

A partir da raiz do repositório do jogo:

```bash
python3 tools/export_catalog.py \
  --game-root games/bettercraft \
  --output ../blockframestudio/src/data/bettercraftCatalog.json
```

Para gerar também as pastas físicas com os assets:

```bash
python3 tools/export_catalog.py \
  --game-root games/bettercraft \
  --output ../blockframestudio/src/data/bettercraftCatalog.json \
  --gentexture
```

Isso cria `textures/` e `models/` ao lado do JSON de saída, colocando todos os arquivos diretamente na pasta correspondente, sem subpastas de mods. Se houver nomes repetidos, o script acrescenta o nome do mod ao arquivo para não sobrescrever nada.

Para separar os arquivos por mod, use a opção alternativa:

```bash
python3 tools/export_catalog.py \
  --game-root games/bettercraft \
  --output ../blockframestudio/src/data/bettercraftCatalog.json \
  --gentexture-separated
```

Essa opção cria `textures/<mod>/` e `models/<mod>/`. `--gentexture` e `--gentexture-separated` são mutuamente exclusivas. A opção antiga `--copy-assets` foi removida. No site, abra a aba **TEXTURAS** e use **Importar textures/models** para selecionar os arquivos gerados.

O arquivo JSON final é um array puro. Cada posição contém exatamente:

```json
[
  {
    "type": "node",
    "name": "mcl_amethyst:amethyst_cluster",
    "description": "Amethyst Cluster",
    "drawtype": "plantlike",
    "mesh": null,
    "inventory_image": "mcl_amethyst_amethyst_cluster.png",
    "wield_image": null,
    "tiles": ["mcl_amethyst_amethyst_cluster.png"],
    "paramtype": "none",
    "paramtype2": null
  }
]
```

`type` vale `node` quando o cadastro veio de `register_node` ou `register_multinode`. Vale `item` quando veio de `register_craftitem` ou `register_tool`. O `register_multinode` é expandido usando `shared` e cada entrada de `nodes`, gerando um registro para cada sufixo criado pelo jogo.

O catálogo obtido pelo parser inclui:

- todos os registros encontrados de nós, craftitems e ferramentas;
- `drawtype`, incluindo itens `plantlike`;
- `mesh` e modelos relacionados;
- imagens de inventário e de mão;
- todas as texturas e modelos encontrados durante a varredura; eles podem ser copiados para pastas planas com `--gentexture` ou separados por mod com `--gentexture-separated`, mas não são adicionados ao array JSON para preservar o formato solicitado.

Para usar outro local público dos assets relacionados durante a varredura, passe `--asset-base-url`.

O site `blockframestudio` importa `src/data/bettercraftCatalog.json` durante o build e transforma os registros na paleta de itens e blocos.

## Limitação do parser

O exportador é estático e considera registros cujo primeiro argumento seja um literal de string, como `core.register_node("mcl_core:stone", { ... })`. Registros cujo nome é montado dinamicamente ou resolvido somente em tempo de execução precisam ser materializados em uma fonte de dados adicional para serem detectados.
