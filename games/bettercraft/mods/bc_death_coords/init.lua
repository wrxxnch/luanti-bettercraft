-- ===================================================
-- MOD: bc_death_coords (BetterCraft / Luanti)
-- Estado Default: DESENABLED
-- Requisito: Permissão 'server' for activate/desactivate
-- Commands: /deathcoords <on|off|status> e /lastdeath
-- Installation directory: games/bettercraft/mods/bc_death_coords
-- ===================================================

local bc_death_coords_enabled = false
local last_death_locations = {}

-- Command principal do administrador for alternar status (/deathcoords)
minetest.register_chatcommand("deathcoords", {
    params = "<on|off|status>",
    description = "Ativa ou desativa a exibicao de coordinates de morte no server (Requires permissao SERVER)",
    privs = { server = true }, -- Restrito a administradores do server
    func = function(name, param)
        param = param and param:lower():trim() or ""

        if param == "on" then
            bc_death_coords_enabled = true
            minetest.chat_send_all("[Death Coords] ENABLED pelo administrador " .. name .. "!")
            return true, "Death Coords enabled! Death coordinates will be shown to players."

        elseif param == "off" then
            bc_death_coords_enabled = false
            minetest.chat_send_all("[Death Coords] DESENABLED pelo administrador " .. name .. "!")
            return true, "Death Coords desenabled."

        elseif param == "status" or param == "" then
            local st = bc_death_coords_enabled and "ENABLED" or "DESENABLED"
            return true, "[Death Coords] Status do server: " .. st

        else
            return false, "Usage incorrect! Enter: /deathcoords on | /deathcoords off | /deathcoords status"
        end
    end,
})

-- Intercepta a morte do player e avisa a coordenada exata
minetest.register_on_dieplayer(function(player)
    if not bc_death_coords_enabled then
        return
    end

    local name = player:get_player_name()
    local pos = player:get_pos()

    if pos then
        local x = math.floor(pos.x + 0.5)
        local y = math.floor(pos.y + 0.5)
        local z = math.floor(pos.z + 0.5)

        last_death_locations[name] = { x = x, y = y, z = z }

        local msg = string.format("☠️ [Morte] Voce morreu em: X = %d | Y = %d | Z = %d", x, y, z)
        minetest.chat_send_player(name, msg)
        minetest.log("action", string.format("[bc_death_coords] Player %s morreu na position (%d, %d, %d)", name, x, y, z))
    end
end)

-- Command secundário público for consultar a última morte individual
minetest.register_chatcommand("lastdeath", {
    params = "",
    description = "Mostra a localizacao da sua ultima morte",
    privs = { interact = true },
    func = function(name, param)
        if not bc_death_coords_enabled then
            return false, "[Death Coords] O sistema is DESENABLED no server."
        end

        local pos = last_death_locations[name]
        if pos then
            return true, string.format("☠️ Sua ultima morte registrada foi em: X = %d, Y = %d, Z = %d", pos.x, pos.y, pos.z)
        else
            return false, "Noa morte registrada recentemente for voce nesta sessao."
        end
    end,
})

minetest.log("action", "[bc_death_coords] Mod Death Coords loaded in games/bettercraft/mods/bc_death_coords (Default: DESENABLED, Privilege: server).")
