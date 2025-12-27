-- Mod: last_death_coords
-- Funções:
-- - Mantém o inventário ao morrer (keepInventory)
-- - Salva a última posição de morte
-- - /lastdeath -> mostra coordenadas
-- - /tpdeath -> teleporta para o local da morte

local last_death_positions = {}

---------------------------------------------------
-- KEEP INVENTORY (Mineclonia / Minetest)
---------------------------------------------------

-- Para Mineclonia (gamerule)
if minetest.get_modpath("mcl_gamerules") then
    mcl_gamerules.set("keepInventory", true)
    minetest.log("action", "[last_death] keepInventory ativado (Mineclonia)")
else
    -- Para Minetest padrão
    minetest.settings:set_bool("keep_inventory", true)
    minetest.log("action", "[last_death] keep_inventory ativado (Minetest)")
end

---------------------------------------------------
-- REGISTRA MORTE DO JOGADOR
---------------------------------------------------

minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    local pos = player:get_pos()

    if name and pos then
        last_death_positions[name] = vector.round(pos)

        local msg = string.format(
            "Você morreu em: X: %d, Y: %d, Z: %d",
            pos.x, pos.y, pos.z
        )

        minetest.chat_send_player(name, "[Morte] " .. msg)
        minetest.log("action", name .. " morreu em " .. minetest.pos_to_string(pos))
    end
end)

---------------------------------------------------
-- COMANDO /lastdeath
---------------------------------------------------

minetest.register_chatcommand("lastdeath", {
    description = "Mostra as coordenadas da sua última morte",
    func = function(name)
        local pos = last_death_positions[name]

        if not pos then
            return false, "Nenhuma morte registrada nesta sessão."
        end

        return true, string.format(
            "Sua última morte foi em: X: %d, Y: %d, Z: %d",
            pos.x, pos.y, pos.z
        )
    end
})

---------------------------------------------------
-- COMANDO /tpdeath
---------------------------------------------------

minetest.register_chatcommand("tpdeath", {
    description = "Teleporta você para o local da sua última morte",
    privs = {interact = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local pos = last_death_positions[name]

        if not player then
            return false, "Jogador não encontrado."
        end

        if not pos then
            return false, "Nenhuma morte registrada ainda."
        end

        player:set_pos(pos)
        return true, "Teleportado para o local da sua última morte."
    end
})
