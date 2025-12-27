-- Simple Keep Inventory v3 para Mineclonia/VoxeLibre
-- Mantém seus itens quando você morre (versão compatível)

local modname = minetest.get_current_modname()

-- Tabela para armazenar inventários
local player_inventories = {}

-- Registra callback com PRIORIDADE ALTA para executar ANTES do mcl_death_drop
-- Salva o inventário e limpa ANTES do sistema padrão dropar
minetest.register_on_dieplayer(function(player, reason)
    local player_name = player:get_player_name()
    local inv = player:get_inventory()
    
    -- Salva todos os inventários
    player_inventories[player_name] = {
        main = {},
        craft = {},
        armor = {},
        offhand = {}
    }
    
    -- Copia inventário principal
    local main_list = inv:get_list("main")
    if main_list then
        for i, item in ipairs(main_list) do
            player_inventories[player_name].main[i] = ItemStack(item)
        end
    end
    
    -- Copia crafting
    local craft_list = inv:get_list("craft")
    if craft_list then
        for i, item in ipairs(craft_list) do
            player_inventories[player_name].craft[i] = ItemStack(item)
        end
    end
    
    -- Copia armadura
    local armor_list = inv:get_list("armor")
    if armor_list then
        for i, item in ipairs(armor_list) do
            player_inventories[player_name].armor[i] = ItemStack(item)
        end
    end
    
    -- Copia offhand
    local offhand_list = inv:get_list("offhand")
    if offhand_list then
        for i, item in ipairs(offhand_list) do
            player_inventories[player_name].offhand[i] = ItemStack(item)
        end
    end
    
    minetest.log("action", "[Keep Inventory] Inventário de " .. player_name .. " salvo")
end)

-- Restaura o inventário quando o jogador respawna
minetest.register_on_respawnplayer(function(player)
    local player_name = player:get_player_name()
    
    -- Aguarda para garantir que o jogador respawnou
    minetest.after(0.3, function()
        if player and player:is_player() and player_inventories[player_name] then
            local inv = player:get_inventory()
            
            -- Restaura inventário principal
            if player_inventories[player_name].main then
                inv:set_list("main", player_inventories[player_name].main)
            end
            
            -- Restaura crafting
            if player_inventories[player_name].craft then
                inv:set_list("craft", player_inventories[player_name].craft)
            end
            
            -- Restaura armadura
            if player_inventories[player_name].armor then
                inv:set_list("armor", player_inventories[player_name].armor)
            end
            
            -- Restaura offhand
            if player_inventories[player_name].offhand then
                inv:set_list("offhand", player_inventories[player_name].offhand)
            end
            
            -- Limpa os dados salvos
            player_inventories[player_name] = nil
            
            minetest.chat_send_player(player_name, "✓ Seus itens foram mantidos!")
            minetest.log("action", "[Keep Inventory] Inventário de " .. player_name .. " restaurado")
        end
    end)
    
    return false
end)

-- Limpa dados ao sair
minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    player_inventories[player_name] = nil
end)

-- SOLUÇÃO: Registra listas vazias no mcl_death_drop para não dropar nada
if minetest.get_modpath("mcl_death_drop") and mcl_death_drop then
    -- Sobrescreve as listas para não dropar itens
    minetest.after(0, function()
        -- Remove os drops registrados
        if mcl_death_drop.registered_dropped_lists then
            mcl_death_drop.registered_dropped_lists = {}
        end
    end)
end

minetest.log("action", "[Keep Inventory v3] Mod carregado!")
