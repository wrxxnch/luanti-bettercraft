# Ice Caves — referências de implementação

- Minecraft Wiki: https://minecraft.wiki/w/Ice_Caves
  - Ice Caves são biomas de caverna em temperaturas baixas, normalmente sob biomas nevados e, às vezes, taigas.
  - Paredes principalmente de packed ice com blobs de calcite; chão com snow e ice crystals; icicles no teto; ores em stone/deepslate.
  - Glow lichen, dirt e granite não geram; água de aquíferos permanece fluida.
- Minecraft Java Snapshot 26.4 Snapshot 3: https://www.minecraft.net/en-us/article/minecraft-26-4-snapshot-3
  - Escopo oficial: Ice Caves, Ice Crystals, Icicles, Frostbite, Freezing e Ice Ball.
  - Ice Crystal é luminoso e quebra sem suporte.
  - Icicles são formações de teto, podem crescer até 5 blocos, quebram com luz próxima e causam dano ao cair.
- Luanti mapgen features: https://docs.luanti.org/for-creators/mapgen/features/
  - Cavernas são cavidades subterrâneas; biomas podem controlar líquidos e decorações.
- Luanti Modding Book: https://rubenwardy.com/minetest_modding_book/en/advmap/biomesdeco.html
  - Biomas e decorações/schematics são registrados por API e podem ser restritos a biomas e alturas.

## Decisão

Esta etapa implementa o bioma IceCaves no levelgen existente do Bettercraft, paredes de packed ice, formações de calcite/stone/deepslate via o pipeline existente, e um mod `mcl_ice_caves` com Ice Crystals e Icicles gerados no ambiente de caverna. Frostbite, Freezing e Ice Ball ficam explicitamente fora desta etapa por falta de uma base de entidade/efeito correspondente no repositório; devem ser adicionados em uma etapa própria.
