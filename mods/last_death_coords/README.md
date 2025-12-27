# Mod: last_death_coords

## Visão Geral
O mod **last_death_coords** para Mineclonia (Minetest) rastreia e exibe as coordenadas exatas onde o jogador morreu pela última vez. Isso é extremamente útil para que os jogadores possam retornar rapidamente ao local da morte para recuperar seus itens.

## Funcionalidades
*   **Notificação de Morte:** Exibe as coordenadas X, Y e Z da morte no chat do jogo imediatamente após o jogador morrer.
*   **Comando de Chat:** Permite que o jogador consulte as últimas coordenadas de morte a qualquer momento usando um comando de chat.
*   **Persistência de Dados:** As coordenadas são salvas de forma persistente, o que significa que elas não serão perdidas mesmo se o servidor for reiniciado.

## Instalação
1.  **Baixe** o arquivo `last_death_coords.zip`.
2.  **Descompacte** o arquivo. Você obterá uma pasta chamada `last_death_coords`.
3.  **Mova** a pasta `last_death_coords` para o diretório de mods do seu mundo Mineclonia/Minetest.
    *   O caminho típico é `~/.minetest/mods/` ou `~/.minetest/worlds/<nome_do_seu_mundo>/worldmods/`.
4.  **Ative** o mod no menu de configurações do mundo antes de entrar no jogo.

## Uso
### 1. Notificação Automática
Ao morrer, você receberá uma mensagem no chat do jogo com a localização exata:
> `[Morte] Você morreu em: X: 123, Y: 45, Z: -678`

### 2. Comando de Chat
Para verificar suas últimas coordenadas de morte a qualquer momento, use o seguinte comando no chat:
```
/lastdeath
```
O mod responderá com a localização registrada:
> `Sua última morte foi em: X: 123, Y: 45, Z: -678`

## Detalhes Técnicos
O mod utiliza o *hook* `minetest.register_on_dieplayer` [1] para capturar o evento de morte do jogador. A posição é obtida através da função `ObjectRef:get_pos()` [1] e armazenada em um arquivo JSON persistente usando `minetest.write_json` e `minetest.read_json` [1].

| Arquivo | Função | Descrição |
| :--- | :--- | :--- |
| `init.lua` | Lógica principal | Contém o registro do *hook* de morte e do comando de chat `/lastdeath`. |
| `mod.conf` | Metadados | Define o nome, descrição e versão do mod. |
| `depends.txt` | Dependências | Indica que o mod não tem dependências obrigatórias de outros mods. |

## Referências
[1] Minetest Lua Modding API Reference. *Documentação oficial da API Minetest, que é a base para o Mineclonia.*
