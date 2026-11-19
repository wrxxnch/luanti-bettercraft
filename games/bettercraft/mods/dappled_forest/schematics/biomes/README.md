# MTS por bioma

Coloque os arquivos `.mts` diretamente na subpasta com o nome do bioma. O mod descobre os arquivos no carregamento do mundo, valida o bioma da coluna e seleciona no máximo uma estrutura por chunk candidato (chance de 1 em 40).

| Pasta | Biomas registrados aceitos |
| --- | --- |
| `taiga/` | Taiga, SnowyTaiga, ColdTaiga, OldGrowthSpruceTaiga |
| `acacia_forest/` | Savanna, SavannaM, Savannah, SavannahM, SavannaPlateau, WindsweptSavanna |
| `dappled_forest/` | dappled_forest, DappledForest |
| `pale_garden/` | PaleGarden, pale_garden |
| `pine_forest/` | OldGrowthPineTaiga, MegaTaiga |
| `jungle/` | Jungle, JungleM, SparseJungle, BambooJungle, JungleEdge, JungleEdgeM |

Para a estrutura **Abandoned Camp**, salve os schematics numerados em `dappled_forest/`, por exemplo `abandoned_camp1.mts`, `abandoned_camp2.mts` e `abandoned_camp3.mts`. Todos são descobertos e uma variante é escolhida aleatoriamente quando a estrutura for gerada. `abandoned_camp.mts` e outros arquivos `.mts` também continuam aceitos. Os schematics precisam ter o piso na base e ser compatíveis com rotação aleatória.

Novos arquivos `.mts` nas pastas existentes não exigem mudanças no Lua, mas requerem reiniciar o mundo para que a descoberta ocorra novamente.
