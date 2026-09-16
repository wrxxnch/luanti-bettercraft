-- ===================================================
-- MOD: bc_schemedit (BetterCraft / Luanti)
-- Estado Default: DESENABLED
-- Requisito: Permissão 'server' for activate/desactivate
-- Commands: /bc_schemedit <on|off|p1|p2|save <nome>|status>
-- Installation directory: games/bettercraft/mods/bc_schemedit
-- ===================================================

local bc_schemedit_enabled = false
local player_p1 = {}
local player_p2 = {}

minetest.register_chatcommand("bc_schemedit", {
    params = "<on|off|p1|p2|save <nome>|status>",
    description = "Schematic editor and .mts exporter (requires the server privilege)",
    privs = { server = true }, -- Restrito a Administradores
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found." end

        local args = {}
        for word in string.gmatch(param or "", "%S+") do
            table.insert(args, word)
        end

        local subcmd = args[1] and args[1]:lower() or ""

        if subcmd == "on" then
            bc_schemedit_enabled = true
            return true, "[SchemEdit] The editor de schematics foi ENABLED."

        elseif subcmd == "off" then
            bc_schemedit_enabled = false
            player_p1[name] = nil
            player_p2[name] = nil
            return true, "[SchemEdit] The editor de schematics foi DESENABLED e selections cleared."

        elseif subcmd == "p1" then
            if not bc_schemedit_enabled then
                return false, "[SchemEdit] The editor is DESENABLED. Enable with '/bc_schemedit on'"
            end
            local pos = vector.round(player:get_pos())
            player_p1[name] = pos
            return true, string.format("[SchemEdit] Posicao 1 definida em (X=%d, Y=%d, Z=%d)", pos.x, pos.y, pos.z)

        elseif subcmd == "p2" then
            if not bc_schemedit_enabled then
                return false, "[SchemEdit] The editor is DESENABLED. Enable with '/bc_schemedit on'"
            end
            local pos = vector.round(player:get_pos())
            player_p2[name] = pos
            return true, string.format("[SchemEdit] Posicao 2 definida em (X=%d, Y=%d, Z=%d)", pos.x, pos.y, pos.z)

        elseif subcmd == "save" then
            if not bc_schemedit_enabled then
                return false, "[SchemEdit] The editor is DESENABLED. Enable with '/bc_schemedit on'"
            end

            local schem_name = args[2]
            if not schem_name or schem_name == "" then
                return false, "Specify o file name! Exemplo: /bc_schemedit save my_build"
            end

            local p1 = player_p1[name]
            local p2 = player_p2[name]
            if not p1 or not p2 then
                return false, "Voce precisa definir a Posicao 1 (/bc_schemedit p1) e a Posicao 2 (/bc_schemedit p2) antes de salvar!"
            end

            local minp = { x = math.min(p1.x, p2.x), y = math.min(p1.y, p2.y), z = math.min(p1.z, p2.z) }
            local maxp = { x = math.max(p1.x, p2.x), y = math.max(p1.y, p2.y), z = math.max(p1.z, p2.z) }

            local filepath = minetest.get_worldpath() .. "/" .. schem_name .. ".mts"
            local success = minetest.create_schematic(minp, maxp, nil, filepath)

            if success then
                return true, string.format("★ Schematic '%s.mts' saved successfully in the world!", schem_name)
            else
                return false, "Error ao tentar salvar o file schematic no server."
            end

        elseif subcmd == "status" or subcmd == "" then
            local pos1_str = player_p1[name] and string.format("(%d,%d,%d)", player_p1[name].x, player_p1[name].y, player_p1[name].z) or "Nao definida"
            local pos2_str = player_p2[name] and string.format("(%d,%d,%d)", player_p2[name].x, player_p2[name].y, player_p2[name].z) or "Nao definida"
            return true, string.format("[SchemEdit] Status: %s | P1: %s | P2: %s", (bc_schemedit_enabled and "ENABLED" or "DESENABLED"), pos1_str, pos2_str)

        else
            return false, "Command invalid! Usage: /bc_schemedit <on|off|p1|p2|save <nome>|status>"
        end
    end,
})

minetest.log("action", "[bc_schemedit] Mod SchemEdit loaded in games/bettercraft/mods/bc_schemedit (Default: DESENABLED, Privilege: server).")
